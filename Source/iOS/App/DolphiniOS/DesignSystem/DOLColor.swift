// Copyright 2026 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

import UIKit

// Semantic color tokens for the Tier 1 "classic" design system.
// Values must stay in sync with DesignTokens.json — see DESIGN_TOKENS.md.
enum DOLColor {
  static let backgroundPrimary = dynamic(light: "#F5F6F8", dark: "#0B0C10")
  static let backgroundSecondary = dynamic(light: "#FFFFFF", dark: "#16171C")

  static let accentSolid = dynamic(light: "#2455FF", dark: "#4B7CFF")
  static let accentGradientStart = UIColor(hex: "#3217FF")
  static let accentGradientEnd = UIColor(hex: "#1792FF")

  static let textPrimary = dynamic(light: "#101114", dark: "#F2F3F5")
  static let textSecondary = dynamic(light: "#5B5F6B", dark: "#9BA0AC")

  static let borderHairline = UIColor { traits in
    traits.userInterfaceStyle == .dark
      ? UIColor.white.withAlphaComponent(0.10)
      : UIColor.black.withAlphaComponent(0.08)
  }

  static let destructive = dynamic(light: "#E5484D", dark: "#F2555A")
  static let success = dynamic(light: "#2FB673", dark: "#3ECB86")

  // Simulated glass fill — see the "Glass simulation note" in DESIGN_TOKENS.md
  // for why Tier 1's opacity is intentionally more conservative than Tier 3's.
  static let glassFill = UIColor { traits in
    traits.userInterfaceStyle == .dark
      ? UIColor.white.withAlphaComponent(0.08)
      : UIColor.white.withAlphaComponent(0.62)
  }

  static var accentGradientLayer: CAGradientLayer {
    let layer = CAGradientLayer()
    layer.colors = [accentGradientStart.cgColor, accentGradientEnd.cgColor]
    layer.startPoint = CGPoint(x: 0, y: 0)
    layer.endPoint = CGPoint(x: 1, y: 1)
    return layer
  }

  private static func dynamic(light: String, dark: String) -> UIColor {
    UIColor { traits in
      traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
    }
  }
}

private extension UIColor {
  convenience init(hex: String) {
    var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    sanitized = sanitized.replacingOccurrences(of: "#", with: "")

    var rgb: UInt64 = 0
    Scanner(string: sanitized).scanHexInt64(&rgb)

    let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
    let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
    let b = CGFloat(rgb & 0x0000FF) / 255.0

    self.init(red: r, green: g, blue: b, alpha: 1.0)
  }
}
