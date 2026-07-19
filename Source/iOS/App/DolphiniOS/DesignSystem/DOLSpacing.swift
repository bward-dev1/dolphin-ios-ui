// Copyright 2026 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

import CoreGraphics
import Foundation

enum DOLSpacing {
  static let xs: CGFloat = 4
  static let sm: CGFloat = 8
  static let md: CGFloat = 16
  static let lg: CGFloat = 24
  static let xl: CGFloat = 40
}

enum DOLRadius {
  static let sm: CGFloat = 8
  static let md: CGFloat = 14
  static let lg: CGFloat = 22
  static let pill: CGFloat = 999
}

enum DOLMotion {
  static let durationFast: TimeInterval = 0.18
  static let durationStandard: TimeInterval = 0.32
  static let durationSlow: TimeInterval = 0.5

  // Matches DesignTokens.json's motion.spring — damping/response tuned for
  // UIViewPropertyAnimator's dampingRatio/duration parameters.
  static let springDampingRatio: CGFloat = 0.86
  static let springResponse: TimeInterval = 0.4
}
