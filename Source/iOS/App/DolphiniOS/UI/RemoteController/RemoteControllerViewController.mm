// Copyright 2026 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

#import "RemoteControllerViewController.h"

#import <CoreMotion/CoreMotion.h>

#import "DSUServerManager.h"

static const uint16_t kDefaultDSUPort = 26760;

@interface RemoteControllerViewController ()
@end

@implementation RemoteControllerViewController {
  CMMotionManager* _motionManager;
  UIInterfaceOrientation _orientation;

  UILabel* _addressLabel;
  UILabel* _statusLabel;
  UIButton* _startStopButton;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Remote Controller";
  self.view.backgroundColor = [UIColor systemBackgroundColor];

  _motionManager = [[CMMotionManager alloc] init];

  [self buildUI];
  [self updateStatusLabels];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(orientationChanged)
                                               name:UIApplicationDidChangeStatusBarOrientationNotification
                                             object:nil];
  [self orientationChanged];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self stopServing];
}

- (void)orientationChanged {
  _orientation = UIApplication.sharedApplication.statusBarOrientation;
}

#pragma mark - UI construction

- (UIButton*)makeControllerButtonWithTitle:(NSString*)title tag:(NSInteger)tag {
  UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
  [button setTitle:title forState:UIControlStateNormal];
  button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
  button.backgroundColor = [UIColor secondarySystemBackgroundColor];
  button.layer.cornerRadius = 12;
  button.tag = tag;
  button.translatesAutoresizingMaskIntoConstraints = NO;
  [button.widthAnchor constraintEqualToConstant:56].active = YES;
  [button.heightAnchor constraintEqualToConstant:56].active = YES;
  [button addTarget:self action:@selector(controllerButtonDown:) forControlEvents:UIControlEventTouchDown];
  [button addTarget:self action:@selector(controllerButtonUp:)
      forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
  return button;
}

- (void)controllerButtonDown:(UIButton*)sender {
  [[DSUServerManager shared] setButton:sender.tag pressed:YES];
}

- (void)controllerButtonUp:(UIButton*)sender {
  [[DSUServerManager shared] setButton:sender.tag pressed:NO];
}

- (void)buildUI {
  _addressLabel = [[UILabel alloc] init];
  _addressLabel.font = [UIFont monospacedSystemFontOfSize:20 weight:UIFontWeightBold];
  _addressLabel.textAlignment = NSTextAlignmentCenter;
  _addressLabel.translatesAutoresizingMaskIntoConstraints = NO;

  _statusLabel = [[UILabel alloc] init];
  _statusLabel.font = [UIFont systemFontOfSize:14];
  _statusLabel.textColor = [UIColor secondaryLabelColor];
  _statusLabel.textAlignment = NSTextAlignmentCenter;
  _statusLabel.numberOfLines = 0;
  _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;

  _startStopButton = [UIButton buttonWithType:UIButtonTypeSystem];
  _startStopButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
  [_startStopButton addTarget:self action:@selector(startStopTapped) forControlEvents:UIControlEventTouchUpInside];
  _startStopButton.translatesAutoresizingMaskIntoConstraints = NO;

  UIStackView* topStack = [[UIStackView alloc] initWithArrangedSubviews:@[
    _addressLabel, _statusLabel, _startStopButton
  ]];
  topStack.axis = UILayoutConstraintAxisVertical;
  topStack.spacing = 8;
  topStack.alignment = UIStackViewAlignmentCenter;
  topStack.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:topStack];

  // D-pad (left side): a 3x3 grid of buttons, only the plus-shape ones populated.
  UIButton* dpadUp = [self makeControllerButtonWithTitle:@"^" tag:DSUButtonDpadUp];
  UIButton* dpadDown = [self makeControllerButtonWithTitle:@"v" tag:DSUButtonDpadDown];
  UIButton* dpadLeft = [self makeControllerButtonWithTitle:@"<" tag:DSUButtonDpadLeft];
  UIButton* dpadRight = [self makeControllerButtonWithTitle:@">" tag:DSUButtonDpadRight];

  UIStackView* dpadHorizontal = [[UIStackView alloc] initWithArrangedSubviews:@[ dpadLeft, dpadRight ]];
  dpadHorizontal.axis = UILayoutConstraintAxisHorizontal;
  dpadHorizontal.spacing = 56;

  UIStackView* dpad = [[UIStackView alloc] initWithArrangedSubviews:@[ dpadUp, dpadHorizontal, dpadDown ]];
  dpad.axis = UILayoutConstraintAxisVertical;
  dpad.alignment = UIStackViewAlignmentCenter;
  dpad.spacing = 8;
  dpad.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:dpad];

  // Face buttons (right side): Triangle/Circle/Cross/Square diamond.
  UIButton* faceTriangle = [self makeControllerButtonWithTitle:@"Y" tag:DSUButtonTriangle];
  UIButton* faceCircle = [self makeControllerButtonWithTitle:@"B" tag:DSUButtonCircle];
  UIButton* faceCross = [self makeControllerButtonWithTitle:@"A" tag:DSUButtonCross];
  UIButton* faceSquare = [self makeControllerButtonWithTitle:@"X" tag:DSUButtonSquare];

  UIStackView* faceHorizontal = [[UIStackView alloc] initWithArrangedSubviews:@[ faceSquare, faceCircle ]];
  faceHorizontal.axis = UILayoutConstraintAxisHorizontal;
  faceHorizontal.spacing = 56;

  UIStackView* faceButtons = [[UIStackView alloc] initWithArrangedSubviews:@[ faceTriangle, faceHorizontal, faceCross ]];
  faceButtons.axis = UILayoutConstraintAxisVertical;
  faceButtons.alignment = UIStackViewAlignmentCenter;
  faceButtons.spacing = 8;
  faceButtons.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:faceButtons];

  // Shoulder buttons + Options/Share, along the top.
  UIButton* l1 = [self makeControllerButtonWithTitle:@"L1" tag:DSUButtonL1];
  UIButton* l2 = [self makeControllerButtonWithTitle:@"L2" tag:DSUButtonL2];
  UIButton* r1 = [self makeControllerButtonWithTitle:@"R1" tag:DSUButtonR1];
  UIButton* r2 = [self makeControllerButtonWithTitle:@"R2" tag:DSUButtonR2];
  UIButton* share = [self makeControllerButtonWithTitle:@"-" tag:DSUButtonShare];
  UIButton* options = [self makeControllerButtonWithTitle:@"+" tag:DSUButtonOptions];

  UIStackView* leftShoulders = [[UIStackView alloc] initWithArrangedSubviews:@[ l2, l1 ]];
  leftShoulders.axis = UILayoutConstraintAxisHorizontal;
  leftShoulders.spacing = 8;
  leftShoulders.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:leftShoulders];

  UIStackView* rightShoulders = [[UIStackView alloc] initWithArrangedSubviews:@[ r1, r2 ]];
  rightShoulders.axis = UILayoutConstraintAxisHorizontal;
  rightShoulders.spacing = 8;
  rightShoulders.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:rightShoulders];

  UIStackView* centerButtons = [[UIStackView alloc] initWithArrangedSubviews:@[ share, options ]];
  centerButtons.axis = UILayoutConstraintAxisHorizontal;
  centerButtons.spacing = 24;
  centerButtons.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:centerButtons];

  [NSLayoutConstraint activateConstraints:@[
    [topStack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:16],
    [topStack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    [topStack.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:16],
    [topStack.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-16],

    [leftShoulders.topAnchor constraintEqualToAnchor:topStack.bottomAnchor constant:32],
    [leftShoulders.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:32],
    [rightShoulders.topAnchor constraintEqualToAnchor:topStack.bottomAnchor constant:32],
    [rightShoulders.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-32],
    [centerButtons.topAnchor constraintEqualToAnchor:leftShoulders.bottomAnchor constant:16],
    [centerButtons.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],

    [dpad.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40],
    [dpad.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-60],

    [faceButtons.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-40],
    [faceButtons.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-60],
  ]];

  [self updateStartStopTitle];
}

#pragma mark - Start/stop

- (void)startStopTapped {
  if ([DSUServerManager shared].isRunning) {
    [self stopServing];
  } else {
    [self startServing];
  }
  [self updateStartStopTitle];
  [self updateStatusLabels];
}

- (void)updateStartStopTitle {
  [_startStopButton setTitle:([DSUServerManager shared].isRunning ? @"Stop" : @"Start")
                    forState:UIControlStateNormal];
}

- (void)startServing {
  NSError* error = nil;
  if (![[DSUServerManager shared] startOnPort:kDefaultDSUPort error:&error]) {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Couldn't Start"
        message:@"Failed to open the network port. Try again, or restart the app if this "
                @"keeps happening."
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    return;
  }

  [self startMotionUpdates];
}

- (void)stopServing {
  [_motionManager stopAccelerometerUpdates];
  [_motionManager stopGyroUpdates];
  [[DSUServerManager shared] stop];
}

- (void)updateStatusLabels {
  DSUServerManager* manager = [DSUServerManager shared];
  if (manager.isRunning) {
    _addressLabel.text = [NSString stringWithFormat:@"%@ : %u", manager.localIPAddress ?: @"?", manager.port];
    _statusLabel.text = [NSString stringWithFormat:@"Enter this on the host device's Remote "
                          @"Controller (DSU) settings. %lu connected.",
                          (unsigned long)manager.connectedClientCount];
  } else {
    _addressLabel.text = @"Not running";
    _statusLabel.text = @"Tap Start, then enter the address shown here into the host device's "
                         @"Settings > Controllers > Remote Controller (DSU).";
  }
}

#pragma mark - Motion

- (void)startMotionUpdates {
  if (!_motionManager.accelerometerAvailable || !_motionManager.gyroAvailable) {
    return;
  }

  const double updateInterval = 1.0 / 60.0;
  _motionManager.accelerometerUpdateInterval = updateInterval;
  _motionManager.gyroUpdateInterval = updateInterval;

  __weak RemoteControllerViewController* weakSelf = self;

  [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue new]
                                        withHandler:^(CMAccelerometerData* _Nullable data, NSError* _Nullable error) {
    if (data == nil) {
      return;
    }
    [weakSelf handleAccelerometerData:data.acceleration];
  }];

  [_motionManager startGyroUpdatesToQueue:[NSOperationQueue new]
                               withHandler:^(CMGyroData* _Nullable data, NSError* _Nullable error) {
    if (data == nil) {
      return;
    }
    [weakSelf handleGyroData:data.rotationRate];
  }];
}

// Matches TCDeviceMotion's device-orientation correction so a remote controller behaves the
// same way the local touch controller's motion does.
- (void)handleAccelerometerData:(CMAcceleration)acceleration {
  double x, y;
  double z = acceleration.z;

  switch (_orientation) {
  case UIInterfaceOrientationPortrait:
  case UIInterfaceOrientationUnknown:
    x = -acceleration.x;
    y = -acceleration.y;
    break;
  case UIInterfaceOrientationLandscapeRight:
    x = acceleration.y;
    y = -acceleration.x;
    break;
  case UIInterfaceOrientationPortraitUpsideDown:
    x = acceleration.x;
    y = acceleration.y;
    break;
  case UIInterfaceOrientationLandscapeLeft:
    x = -acceleration.y;
    y = acceleration.x;
    break;
  default:
    return;
  }

  // CMAcceleration is already in G's, same unit DSU expects - no conversion needed. But DSU's
  // axis convention is (x=left/right, y=up/down, z=forward/backward), while x/y/z here follow
  // TCDeviceMotion's local convention (x=left/right, y=forward/backward, z=up/down) - swap y
  // and z to match what the host's DSU client actually expects.
  [[DSUServerManager shared] setAccelerationX:(float)x y:(float)z z:(float)y];
}

- (void)handleGyroData:(CMRotationRate)rotationRate {
  double x, y;
  const double z = rotationRate.z;

  switch (_orientation) {
  case UIInterfaceOrientationPortrait:
  case UIInterfaceOrientationUnknown:
    x = -rotationRate.x;
    y = -rotationRate.y;
    break;
  case UIInterfaceOrientationLandscapeRight:
    x = rotationRate.y;
    y = -rotationRate.x;
    break;
  case UIInterfaceOrientationPortraitUpsideDown:
    x = rotationRate.x;
    y = rotationRate.y;
    break;
  case UIInterfaceOrientationLandscapeLeft:
    x = -rotationRate.y;
    y = rotationRate.x;
    break;
  default:
    return;
  }

  // CMGyroData is in radians/sec; DSU expects degrees/sec.
  const double radToDeg = 180.0 / M_PI;
  [[DSUServerManager shared] setRotationRatePitch:(float)(x * radToDeg)
                                               yaw:(float)(z * radToDeg)
                                              roll:(float)(y * radToDeg)];
}

@end
