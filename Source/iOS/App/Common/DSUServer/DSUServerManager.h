// Copyright 2026 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Broadcasts this device's touch-controller buttons/sticks and motion (gyro+accel) over the
// network using Dolphin's own CemuHook-compatible DSU protocol, so ANOTHER device running
// Dolphin (this app, a desktop build, or any DSU-speaking emulator) can use it as a remote
// motion+button controller via its built-in "DSU Client" input source
// (Settings > Controllers > Remote Controller (DSU) on the receiving device). This device
// needs neither the ROM nor enough RAM/storage to actually run the game - it's a thin input
// source, the receiving device does all the emulation.
@interface DSUServerManager : NSObject

+ (instancetype)shared;

@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, readonly, copy, nullable) NSString* localIPAddress;
@property (nonatomic, readonly) uint16_t port;

// Number of DSU clients (e.g. the host device's Dolphin) currently registered to receive our
// input stream. 0 means nobody has connected yet.
@property (nonatomic, readonly) NSUInteger connectedClientCount;

- (BOOL)startOnPort:(uint16_t)port error:(NSError* _Nullable* _Nullable)error;
- (void)stop;

// Button state. `index` matches DSUButton below.
- (void)setButton:(NSInteger)index pressed:(BOOL)pressed;

- (void)setLeftStickX:(float)x y:(float)y;    // -1...1, y-up
- (void)setRightStickX:(float)x y:(float)y;   // -1...1, y-up

- (void)setAccelerationX:(float)x y:(float)y z:(float)z;       // g's
- (void)setRotationRatePitch:(float)pitch yaw:(float)yaw roll:(float)roll;  // degrees/sec

@end

// Indices for -setButton:pressed:. Named after the DS4-shaped DSU protocol slots - rebind
// them to whatever Wiimote/GameCube button you want on the receiving device's Mapping screen.
typedef NS_ENUM(NSInteger, DSUButton) {
  DSUButtonDpadLeft,
  DSUButtonDpadDown,
  DSUButtonDpadRight,
  DSUButtonDpadUp,
  DSUButtonOptions,
  DSUButtonR3,
  DSUButtonL3,
  DSUButtonShare,
  DSUButtonSquare,
  DSUButtonCross,
  DSUButtonCircle,
  DSUButtonTriangle,
  DSUButtonR1,
  DSUButtonL1,
  DSUButtonR2,
  DSUButtonL2,
  DSUButtonPS,
  DSUButtonTouch,
  DSUButtonCount,
};

NS_ASSUME_NONNULL_END
