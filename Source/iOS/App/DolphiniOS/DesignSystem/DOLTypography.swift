// Copyright 2026 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

import UIKit

// Dynamic-Type-aware type scale. Always resolve fonts through these tokens
// rather than hardcoding point sizes, so every screen scales with the
// user's preferred text size for free.
enum DOLTypography {
  static var display: UIFont { font(.largeTitle, weight: .bold) }
  static var title: UIFont { font(.title2, weight: .semibold) }
  static var headline: UIFont { font(.headline, weight: .semibold) }
  static var body: UIFont { font(.body, weight: .regular) }
  static var caption: UIFont { font(.footnote, weight: .regular) }

  private static func font(_ style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
    let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
    let base = UIFont.systemFont(ofSize: descriptor.pointSize, weight: weight)
    return UIFontMetrics(forTextStyle: style).scaledFont(for: base)
  }
}
