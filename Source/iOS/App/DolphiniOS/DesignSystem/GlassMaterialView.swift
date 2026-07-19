// Copyright 2026 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

import UIKit

// A reusable "glass card/bar" component that simulates Liquid Glass on
// pre-iOS-26 devices using UIVisualEffectView + hairline border + soft
// shadow. See the "Glass simulation note" in DESIGN_TOKENS.md.
final class GlassMaterialView: UIView {
  private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
  private let tintView = UIView()

  // The content view to add subviews to — never add subviews directly to
  // GlassMaterialView itself, they'd render behind the blur.
  let contentView = UIView()

  init(cornerRadius: CGFloat = DOLRadius.md) {
    super.init(frame: .zero)
    setUp(cornerRadius: cornerRadius)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setUp(cornerRadius: DOLRadius.md)
  }

  private func setUp(cornerRadius: CGFloat) {
    layer.cornerRadius = cornerRadius
    layer.cornerCurve = .continuous
    layer.masksToBounds = false
    layer.borderWidth = 1.0 / UIScreen.main.scale
    layer.borderColor = DOLColor.borderHairline.cgColor

    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.06
    layer.shadowRadius = 12
    layer.shadowOffset = CGSize(width: 0, height: 4)

    blurView.translatesAutoresizingMaskIntoConstraints = false
    blurView.layer.cornerRadius = cornerRadius
    blurView.layer.cornerCurve = .continuous
    blurView.clipsToBounds = true
    addSubview(blurView)

    tintView.translatesAutoresizingMaskIntoConstraints = false
    tintView.backgroundColor = DOLColor.glassFill
    tintView.isUserInteractionEnabled = false
    blurView.contentView.addSubview(tintView)

    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.backgroundColor = .clear
    blurView.contentView.addSubview(contentView)

    NSLayoutConstraint.activate([
      blurView.topAnchor.constraint(equalTo: topAnchor),
      blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
      blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
      blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

      tintView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
      tintView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
      tintView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
      tintView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor),

      contentView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor),
    ])
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    layer.borderColor = DOLColor.borderHairline.cgColor
  }
}
