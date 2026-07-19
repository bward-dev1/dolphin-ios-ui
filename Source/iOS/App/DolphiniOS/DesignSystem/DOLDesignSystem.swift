// Copyright 2026 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

import UIKit

// Objective-C-visible facade over the Swift design-system tokens
// (DOLColor/DOLSpacing/DOLRadius/DOLTypography). Plain Swift enums with
// static members are not visible to Obj-C/Obj-C++ at all — only
// @objc-annotated NSObject-derived members are, via the generated
// "DolphiniOS-Swift.h" header (same mechanism OnboardingViewController and
// FirstRunInitializationService.mm already rely on). This class holds no
// values of its own; it forwards to the canonical Swift tokens so there is
// still exactly one source of truth, just two ways to read it.
//
// Most of Settings (Config/Graphics/Controllers/Debug) is Objective-C++,
// tightly coupled to Dolphin's C++ Config:: system — those screens are
// staying Obj-C++ for this Tier 1 pass rather than attempting a Swift
// rewrite, so they need this bridge to use the same tokens as the Swift
// screens (SettingsRootViewController, AboutViewController, onboarding).
@objc(DOLDesignSystem)
final class DOLDesignSystem: NSObject {
  @objc static var backgroundPrimary: UIColor { DOLColor.backgroundPrimary }
  @objc static var backgroundSecondary: UIColor { DOLColor.backgroundSecondary }
  @objc static var accentSolid: UIColor { DOLColor.accentSolid }
  @objc static var textPrimary: UIColor { DOLColor.textPrimary }
  @objc static var textSecondary: UIColor { DOLColor.textSecondary }
  @objc static var borderHairline: UIColor { DOLColor.borderHairline }
  @objc static var destructive: UIColor { DOLColor.destructive }
  @objc static var success: UIColor { DOLColor.success }
  @objc static var glassFill: UIColor { DOLColor.glassFill }

  @objc static var spacingXS: CGFloat { DOLSpacing.xs }
  @objc static var spacingSM: CGFloat { DOLSpacing.sm }
  @objc static var spacingMD: CGFloat { DOLSpacing.md }
  @objc static var spacingLG: CGFloat { DOLSpacing.lg }
  @objc static var spacingXL: CGFloat { DOLSpacing.xl }

  @objc static var radiusSM: CGFloat { DOLRadius.sm }
  @objc static var radiusMD: CGFloat { DOLRadius.md }
  @objc static var radiusLG: CGFloat { DOLRadius.lg }
  @objc static var radiusPill: CGFloat { DOLRadius.pill }

  @objc static var fontDisplay: UIFont { DOLTypography.display }
  @objc static var fontTitle: UIFont { DOLTypography.title }
  @objc static var fontHeadline: UIFont { DOLTypography.headline }
  @objc static var fontBody: UIFont { DOLTypography.body }
  @objc static var fontCaption: UIFont { DOLTypography.caption }

  private override init() {}
}
