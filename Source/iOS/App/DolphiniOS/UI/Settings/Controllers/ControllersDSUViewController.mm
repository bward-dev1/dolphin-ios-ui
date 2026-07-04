// Copyright 2026 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

#import "ControllersDSUViewController.h"

#import "InputCommon/ControllerInterface/DualShockUDPClient/DualShockUDPClient.h"

#import "FoundationStringUtil.h"

typedef NS_ENUM(NSInteger, DSURow) {
  DSURowEnabled,
  DSURowAddress,
  DSURowPort,
};

@interface ControllersDSUViewController () <UITextFieldDelegate>
@end

@implementation ControllersDSUViewController {
  UISwitch* _enabledSwitch;
  UITextField* _addressField;
  UITextField* _portField;
}

- (instancetype)init {
  return [super initWithStyle:UITableViewStyleInsetGrouped];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Remote Controller (DSU)";
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

  _enabledSwitch = [[UISwitch alloc] init];
  [_enabledSwitch addTarget:self action:@selector(settingsChanged) forControlEvents:UIControlEventValueChanged];

  _addressField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 160, 30)];
  _addressField.placeholder = @"IP address";
  _addressField.textAlignment = NSTextAlignmentRight;
  _addressField.keyboardType = UIKeyboardTypeDecimalPad;
  _addressField.delegate = self;
  [_addressField addTarget:self action:@selector(settingsChanged) forControlEvents:UIControlEventEditingChanged];

  _portField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
  _portField.placeholder = @"26760";
  _portField.textAlignment = NSTextAlignmentRight;
  _portField.keyboardType = UIKeyboardTypeNumberPad;
  _portField.delegate = self;
  [_portField addTarget:self action:@selector(settingsChanged) forControlEvents:UIControlEventEditingChanged];

  [self loadCurrentSettings];
}

// Config::SERVERS is "description:address:port;description2:address2:port2;..." - this screen
// only manages a single entry (typically all you need: one other device acting as a remote
// controller), so we just read/write the first one.
- (void)loadCurrentSettings {
  _enabledSwitch.on = Config::Get(ciface::DualShockUDPClient::Settings::SERVERS_ENABLED);

  NSString* serversString = CppToFoundationString(Config::Get(ciface::DualShockUDPClient::Settings::SERVERS));
  NSArray<NSString*>* entries = [serversString componentsSeparatedByString:@";"];
  if (entries.count > 0 && entries[0].length > 0) {
    NSArray<NSString*>* parts = [entries[0] componentsSeparatedByString:@":"];
    if (parts.count >= 3) {
      _addressField.text = parts[1];
      _portField.text = parts[2];
    }
  }
}

- (void)settingsChanged {
  Config::SetBaseOrCurrent(ciface::DualShockUDPClient::Settings::SERVERS_ENABLED, (bool)_enabledSwitch.on);

  NSString* address = _addressField.text ?: @"";
  NSString* portString = _portField.text.length > 0 ? _portField.text : @"26760";

  std::string serversValue;
  if (address.length > 0) {
    serversValue = "Remote:" + FoundationToCppString(address) + ":" + FoundationToCppString(portString) + ";";
  }
  Config::SetBaseOrCurrent(ciface::DualShockUDPClient::Settings::SERVERS, serversValue);
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
  [textField resignFirstResponder];
  return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
  return 3;
}

- (nullable NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section {
  return @"Reads button/gyro input from another device on the same WiFi network running "
         @"Remote Controller mode, instead of a physical Wii Remote. Enter the IP address and "
         @"port shown on that device, then bind “DSU Client” as an extra input source "
         @"for a Wii Remote in Controllers > Mapping.";
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.accessoryView = nil;

  switch ((DSURow)indexPath.row) {
  case DSURowEnabled:
    cell.textLabel.text = @"Enabled";
    cell.accessoryView = _enabledSwitch;
    break;
  case DSURowAddress:
    cell.textLabel.text = @"IP Address";
    cell.accessoryView = _addressField;
    break;
  case DSURowPort:
    cell.textLabel.text = @"Port";
    cell.accessoryView = _portField;
    break;
  }

  return cell;
}

@end
