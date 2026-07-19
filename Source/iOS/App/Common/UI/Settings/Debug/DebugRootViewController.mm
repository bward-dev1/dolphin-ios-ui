// Copyright 2022 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

#import "DebugRootViewController.h"

#import "Core/Config/MainSettings.h"

#import "Swift.h"

#import "DOLSwitch.h"
#import "FastmemManager.h"
#import "JitManager.h"
#import "VirtualMFiControllerManager.h"

// Tier 1 "classic" programmatic replacement for DebugSettings.storyboard.
// Same 4 sections/rows and the same behavior as before — only the
// construction (programmatic vs. Interface Builder) and visual styling
// (design-system tokens) changed. Stays Objective-C++ (not Swift): this
// screen reads/writes Dolphin's C++ Config:: system directly, same reasoning
// as Config/Graphics's leaf screens.
//
// The original hid the Controllers/Utility sections in release builds via
// CGFLOAT_MIN row/header/footer heights (#ifndef DEBUG). This version gets
// the same visible result by simply not including those sections' rows in
// the model outside of DEBUG builds — simpler, same behavior.

typedef NS_ENUM(NSInteger, DOLDebugRowKind) {
  DOLDebugRowKindSwitch,
  DOLDebugRowKindAction,
  DOLDebugRowKindDetail,  // title + secondary-colored trailing value
  DOLDebugRowKindInfo,    // title + secondary-colored subtitle line below
};

@interface DOLDebugRow : NSObject

@property (nonatomic) DOLDebugRowKind kind;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy, nullable) NSString* value;
@property (nonatomic, copy, nullable) BOOL (^switchGetter)(void);
@property (nonatomic, copy, nullable) void (^switchSetter)(BOOL);
@property (nonatomic) BOOL switchEnabled;
@property (nonatomic, copy, nullable) void (^action)(void);

@end

@implementation DOLDebugRow
@end

@interface DebugRootViewController ()

@property (nonatomic, strong) NSArray<NSString*>* sectionTitles;
@property (nonatomic, strong) NSArray<NSArray<DOLDebugRow*>*>* sections;

@end

@implementation DebugRootViewController

- (instancetype)init {
  // The storyboard scene this replaces used style="insetGrouped" — a plain
  // -init on UITableViewController defaults to .plain, so this must be
  // explicit or the row grouping regresses visually.
  return [super initWithStyle:UITableViewStyleInsetGrouped];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Debug";
  self.view.backgroundColor = DOLDesignSystem.backgroundPrimary;

  [self buildRowModel];
}

- (void)buildRowModel {
  __weak __typeof(self) weakSelf = self;

  DOLDebugRow* fastmemRow = [DOLDebugRow new];
  fastmemRow.kind = DOLDebugRowKindSwitch;
  fastmemRow.title = @"Fastmem";
  fastmemRow.switchEnabled = [FastmemManager shared].fastmemAvailable;
  fastmemRow.switchGetter = ^BOOL { return Config::Get(Config::MAIN_FASTMEM); };
  fastmemRow.switchSetter = ^(BOOL on) { Config::SetBaseOrCurrent(Config::MAIN_FASTMEM, (bool)on); };

  DOLDebugRow* syncOnIdleSkipRow = [DOLDebugRow new];
  syncOnIdleSkipRow.kind = DOLDebugRowKindSwitch;
  syncOnIdleSkipRow.title = @"Sync on Idle Skip";
  syncOnIdleSkipRow.switchEnabled = YES;
  syncOnIdleSkipRow.switchGetter = ^BOOL { return Config::Get(Config::MAIN_SYNC_ON_SKIP_IDLE); };
  syncOnIdleSkipRow.switchSetter = ^(BOOL on) { Config::SetBaseOrCurrent(Config::MAIN_SYNC_ON_SKIP_IDLE, (bool)on); };

  NSMutableArray<NSString*>* sectionTitles = [NSMutableArray arrayWithObject:@"General"];
  NSMutableArray<NSArray<DOLDebugRow*>*>* sections = [NSMutableArray arrayWithObject:@[ fastmemRow, syncOnIdleSkipRow ]];

#ifdef DEBUG
  DOLDebugRow* mfiRow = [DOLDebugRow new];
  mfiRow.kind = DOLDebugRowKindSwitch;
  mfiRow.title = @"Attach Virtual MFi Controller";
  mfiRow.switchEnabled = YES;
  mfiRow.switchGetter = ^BOOL { return [VirtualMFiControllerManager shared].shouldConnectController; };
  mfiRow.switchSetter = ^(BOOL on) { [VirtualMFiControllerManager shared].shouldConnectController = on; };

  [sectionTitles addObject:@"Controllers"];
  [sections addObject:@[ mfiRow ]];

  DOLDebugRow* resetLaunchTimesRow = [DOLDebugRow new];
  resetLaunchTimesRow.kind = DOLDebugRowKindAction;
  resetLaunchTimesRow.title = @"Reset Launch Times";
  resetLaunchTimesRow.action = ^{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"launch_times"];

    UIAlertController* launchAlert = [UIAlertController alertControllerWithTitle:@"Reset" message:@"launch_times was reset to 0." preferredStyle:UIAlertControllerStyleAlert];
    [launchAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

    [weakSelf presentViewController:launchAlert animated:true completion:nil];
  };

  DOLDebugRow* forceMotionRow = [DOLDebugRow new];
  forceMotionRow.kind = DOLDebugRowKindAction;
  forceMotionRow.title = @"Force Start Motion Updates";
  forceMotionRow.action = ^{
#if TARGET_OS_IOS
    TCDeviceMotion* sharedMotion = [TCDeviceMotion shared];
    [sharedMotion setPort:4];
    [sharedMotion setMotionEnabled:true];
#endif
  };

  [sectionTitles addObject:@"Utility"];
  [sections addObject:@[ resetLaunchTimesRow, forceMotionRow ]];
#endif

  DOLDebugRow* userFolderRow = [DOLDebugRow new];
  userFolderRow.kind = DOLDebugRowKindInfo;
  userFolderRow.title = @"User Folder";
  userFolderRow.value = [UserFolderUtil getUserFolder];

  DOLDebugRow* jitStatusRow = [DOLDebugRow new];
  jitStatusRow.kind = DOLDebugRowKindDetail;
  jitStatusRow.title = @"JIT Acquisition";
  if ([JitManager shared].acquiredJit) {
    NSString* jitType;
    if (@available(iOS 26, *)) {
      jitType = [JitManager shared].deviceHasTxm ? @"TXM" : @"No TXM";
    } else {
      jitType = @"Legacy";
    }
    jitStatusRow.value = [NSString stringWithFormat:@"Acquired (%@)", jitType];
  } else {
    jitStatusRow.value = @"Not Acquired";
  }

  DOLDebugRow* jitErrorRow = [DOLDebugRow new];
  jitErrorRow.kind = DOLDebugRowKindInfo;
  jitErrorRow.title = @"JIT Acquisition Error";
  NSString* jitError = [JitManager shared].acquisitionError;
  jitErrorRow.value = jitError != nil ? jitError : @"(none)";

  DOLDebugRow* fastmemStatusRow = [DOLDebugRow new];
  fastmemStatusRow.kind = DOLDebugRowKindDetail;
  fastmemStatusRow.title = @"Fastmem";
  fastmemStatusRow.value = [FastmemManager shared].fastmemAvailable ? @"Available" : @"Not Available";

  DOLDebugRow* launchTimesRow = [DOLDebugRow new];
  launchTimesRow.kind = DOLDebugRowKindDetail;
  launchTimesRow.title = @"Launch Times";
  NSInteger launchTimes = [[NSUserDefaults standardUserDefaults] integerForKey:@"launch_times"];
  launchTimesRow.value = [NSString stringWithFormat:@"%tu", launchTimes];

  [sectionTitles addObject:@"Environment"];
  [sections addObject:@[ userFolderRow, jitStatusRow, jitErrorRow, fastmemStatusRow, launchTimesRow ]];

  self.sectionTitles = sectionTitles;
  self.sections = sections;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
  return self.sections.count;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
  return self.sectionTitles[section];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
  return self.sections[section].count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  DOLDebugRow* row = self.sections[indexPath.section][indexPath.row];

  // Distinct reuse identifiers per UITableViewCellStyle — style can't change
  // after a cell is created, so mixing styles under one identifier would
  // make the wrong layout appear depending on which cell got recycled.
  // Detail rows (short trailing value, e.g. "Available") use .value1;
  // Info rows (long text, e.g. a filesystem path) use .subtitle so the
  // value gets its own line below the title instead of being squeezed
  // beside it — matches the original storyboard's stacked two-label layout.
  NSString* reuseIdentifier;
  UITableViewCellStyle style;
  switch (row.kind) {
    case DOLDebugRowKindInfo:
      reuseIdentifier = @"DebugRootInfoCell";
      style = UITableViewCellStyleSubtitle;
      break;
    case DOLDebugRowKindDetail:
      reuseIdentifier = @"DebugRootDetailCell";
      style = UITableViewCellStyleValue1;
      break;
    case DOLDebugRowKindSwitch:
    case DOLDebugRowKindAction:
      reuseIdentifier = @"DebugRootPlainCell";
      style = UITableViewCellStyleDefault;
      break;
  }

  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
  }

  // Clear any switch/accessory left over from cell reuse.
  cell.accessoryView = nil;
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.selectionStyle = UITableViewCellSelectionStyleDefault;
  cell.backgroundColor = DOLDesignSystem.backgroundSecondary;
  cell.textLabel.font = DOLDesignSystem.fontBody;
  cell.textLabel.textColor = DOLDesignSystem.textPrimary;
  cell.detailTextLabel.font = DOLDesignSystem.fontBody;
  cell.detailTextLabel.textColor = DOLDesignSystem.textSecondary;
  cell.textLabel.text = row.title;
  cell.detailTextLabel.text = nil;

  switch (row.kind) {
    case DOLDebugRowKindSwitch: {
      cell.selectionStyle = UITableViewCellSelectionStyleNone;

      DOLSwitch* switchView = [DOLUIKitSwitch new];
      switchView.on = row.switchGetter();
      switchView.enabled = row.switchEnabled;
      [switchView addValueChangedTarget:self action:@selector(rowSwitchChanged:)];
      switchView.tag = indexPath.section * 1000 + indexPath.row;
      cell.accessoryView = switchView;
      break;
    }
    case DOLDebugRowKindAction: {
      cell.textLabel.textColor = DOLDesignSystem.accentSolid;
      break;
    }
    case DOLDebugRowKindDetail: {
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.detailTextLabel.text = row.value;
      break;
    }
    case DOLDebugRowKindInfo: {
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.detailTextLabel.text = row.value;
      cell.detailTextLabel.numberOfLines = 0;
      break;
    }
  }

  return cell;
}

- (void)rowSwitchChanged:(DOLSwitch*)sender {
  NSInteger section = sender.tag / 1000;
  NSInteger rowIndex = sender.tag % 1000;
  DOLDebugRow* row = self.sections[section][rowIndex];
  row.switchSetter(sender.on);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:true];

  DOLDebugRow* row = self.sections[indexPath.section][indexPath.row];
  if (row.action != nil) {
    row.action();
  }
}

@end
