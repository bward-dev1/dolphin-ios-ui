// Copyright 2022 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

#import "NKitWarningViewController.h"

#import "Core/Config/MainSettings.h"

#import "Swift.h"

// Tier 1 "classic" programmatic replacement for NKitWarning.xib. Same
// content, same behavior (Cancel/Yes, "don't show this again" switch
// writing Config::MAIN_SKIP_NKIT_WARNING) — only the construction and
// visual styling changed. Stays Obj-C++ (not Swift): writes Config::
// directly, same reasoning as other Obj-C++ screens.

@interface NKitWarningViewController ()

@property (strong, nonatomic, readwrite) DOLSwitch* showSwitch;

@end

@implementation NKitWarningViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = DOLDesignSystem.backgroundPrimary;
  [self layOutContent];
}

- (void)layOutContent {
  CGFloat spacingLG = DOLDesignSystem.spacingLG;
  CGFloat spacingMD = DOLDesignSystem.spacingMD;
  CGFloat spacingSM = DOLDesignSystem.spacingSM;

  UIImageView* iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"exclamationmark.triangle.fill"]];
  iconView.tintColor = DOLDesignSystem.destructive;
  iconView.contentMode = UIViewContentModeScaleAspectFit;
  iconView.translatesAutoresizingMaskIntoConstraints = NO;

  UILabel* titleLabel = [[UILabel alloc] init];
  titleLabel.text = @"NKit Warning";
  titleLabel.font = DOLDesignSystem.fontDisplay;
  titleLabel.textColor = DOLDesignSystem.textPrimary;
  titleLabel.textAlignment = NSTextAlignmentCenter;
  titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

  UILabel* bodyLabel = [[UILabel alloc] init];
  bodyLabel.text =
      @"You are about to run an NKit disc image. NKit disc images cause problems that don't "
      @"happen with normal disc images. These problems include:\n\n"
      @"• The emulated loading times are longer\n"
      @"• You can't use NetPlay with people who have normal disc images\n"
      @"• Input recordings are not compatible between NKit disc images and normal disc images\n"
      @"• Savestates are not compatible between NKit disc images and normal disc images\n"
      @"• Some games can crash, such as Super Paper Mario and Metal Gear Solid: The Twin Snakes\n"
      @"• Wii games don't work at all in older versions of Dolphin and in many other programs\n\n"
      @"Are you sure you want to continue anyway?";
  bodyLabel.font = DOLDesignSystem.fontBody;
  bodyLabel.textColor = DOLDesignSystem.textSecondary;
  bodyLabel.textAlignment = NSTextAlignmentCenter;
  bodyLabel.numberOfLines = 0;
  bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;

  UIScrollView* scrollView = [[UIScrollView alloc] init];
  scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  [scrollView addSubview:bodyLabel];

  UILabel* dontShowLabel = [[UILabel alloc] init];
  dontShowLabel.text = @"Don't show this again";
  dontShowLabel.font = DOLDesignSystem.fontBody;
  dontShowLabel.textColor = DOLDesignSystem.textPrimary;
  dontShowLabel.translatesAutoresizingMaskIntoConstraints = NO;

  self.showSwitch = [DOLUIKitSwitch new];
  self.showSwitch.translatesAutoresizingMaskIntoConstraints = NO;

  UIStackView* switchRow = [[UIStackView alloc] initWithArrangedSubviews:@[ dontShowLabel, self.showSwitch ]];
  switchRow.axis = UILayoutConstraintAxisHorizontal;
  switchRow.translatesAutoresizingMaskIntoConstraints = NO;

  UIButton* cancelButton = [self makeButtonWithTitle:@"Cancel"
                                      backgroundColor:DOLDesignSystem.accentSolid
                                               action:@selector(cancelPressed:)];
  UIButton* yesButton = [self makeButtonWithTitle:@"Yes"
                                   backgroundColor:DOLDesignSystem.destructive
                                            action:@selector(continuePressed:)];

  UIStackView* buttonStack = [[UIStackView alloc] initWithArrangedSubviews:@[ cancelButton, yesButton ]];
  buttonStack.axis = UILayoutConstraintAxisVertical;
  buttonStack.spacing = spacingSM;
  buttonStack.distribution = UIStackViewDistributionFillEqually;
  buttonStack.translatesAutoresizingMaskIntoConstraints = NO;

  [self.view addSubview:iconView];
  [self.view addSubview:titleLabel];
  [self.view addSubview:scrollView];
  [self.view addSubview:switchRow];
  [self.view addSubview:buttonStack];

  [NSLayoutConstraint activateConstraints:@[
    [iconView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:spacingLG],
    [iconView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    [iconView.heightAnchor constraintEqualToConstant:64],
    [iconView.widthAnchor constraintEqualToConstant:64],

    [titleLabel.topAnchor constraintEqualToAnchor:iconView.bottomAnchor constant:spacingMD],
    [titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:spacingLG],
    [titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-spacingLG],

    [scrollView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:spacingLG],
    [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    [scrollView.bottomAnchor constraintEqualToAnchor:switchRow.topAnchor constant:-spacingMD],

    [bodyLabel.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor],
    [bodyLabel.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor],
    [bodyLabel.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor constant:spacingLG],
    [bodyLabel.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor constant:-spacingLG],
    [bodyLabel.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor constant:-(spacingLG * 2)],

    [switchRow.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:spacingLG],
    [switchRow.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-spacingLG],
    [switchRow.bottomAnchor constraintEqualToAnchor:buttonStack.topAnchor constant:-spacingLG],

    [buttonStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:spacingLG],
    [buttonStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-spacingLG],
    [buttonStack.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-spacingLG],
  ]];
}

- (UIButton*)makeButtonWithTitle:(NSString*)title backgroundColor:(UIColor*)backgroundColor action:(SEL)action {
  UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
  [button setTitle:title forState:UIControlStateNormal];
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  button.titleLabel.font = DOLDesignSystem.fontHeadline;
  button.backgroundColor = backgroundColor;
  button.layer.cornerRadius = DOLDesignSystem.radiusMD;
  button.layer.cornerCurve = kCACornerCurveContinuous;
  [button.heightAnchor constraintEqualToConstant:45].active = YES;
  [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
  return button;
}

- (void)cancelPressed:(id)sender {
  [self.delegate didFinishNKitWarningScreenWithResult:false sender:self];
}

- (void)continuePressed:(id)sender {
  Config::SetBase(Config::MAIN_SKIP_NKIT_WARNING, self.showSwitch.on);

  [self.delegate didFinishNKitWarningScreenWithResult:true sender:self];
}

@end
