// Copyright 2026 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

import UIKit

// Net-new first-run welcome screen — DolphiniOS has never had a real
// onboarding flow (BootNotice is update/analytics-consent only). This is
// also the smoke test for the Tier 1 design-system layer: if the tokens and
// GlassMaterialView render correctly here, they're ready to use across the
// rest of the app. Enqueued via BootNoticeManager alongside the existing
// update/analytics notices — see FirstRunInitializationService.mm.
@objc final class OnboardingViewController: UIViewController {
  private let card = GlassMaterialView(cornerRadius: DOLRadius.lg)

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = DOLColor.backgroundPrimary
    layOutContent()
  }

  private func layOutContent() {
    card.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(card)

    let iconView = UIImageView(image: UIImage(systemName: "square.stack.3d.up.fill"))
    iconView.tintColor = DOLColor.accentSolid
    iconView.contentMode = .scaleAspectFit
    iconView.translatesAutoresizingMaskIntoConstraints = false

    let titleLabel = UILabel()
    titleLabel.text = NSLocalizedString("Welcome to DolphiniOS", comment: "Onboarding title")
    titleLabel.font = DOLTypography.display
    titleLabel.textColor = DOLColor.textPrimary
    titleLabel.numberOfLines = 0
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    let bodyLabel = UILabel()
    bodyLabel.text = NSLocalizedString(
      "Play your GameCube and Wii library with controller skins, motion-accurate Wii Remote support, and full NetPlay with friends.",
      comment: "Onboarding body copy"
    )
    bodyLabel.font = DOLTypography.body
    bodyLabel.textColor = DOLColor.textSecondary
    bodyLabel.numberOfLines = 0
    bodyLabel.translatesAutoresizingMaskIntoConstraints = false

    let continueButton = UIButton(type: .system)
    continueButton.setTitle(NSLocalizedString("Continue", comment: "Onboarding continue button"), for: .normal)
    continueButton.titleLabel?.font = DOLTypography.headline
    continueButton.setTitleColor(.white, for: .normal)
    continueButton.backgroundColor = DOLColor.accentSolid
    continueButton.layer.cornerRadius = DOLRadius.pill / 4 // visually pill at this button's fixed height
    continueButton.layer.cornerCurve = .continuous
    continueButton.translatesAutoresizingMaskIntoConstraints = false
    continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)

    card.contentView.addSubview(iconView)
    card.contentView.addSubview(titleLabel)
    card.contentView.addSubview(bodyLabel)
    card.contentView.addSubview(continueButton)

    NSLayoutConstraint.activate([
      card.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: DOLSpacing.lg),
      card.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -DOLSpacing.lg),
      card.centerYAnchor.constraint(equalTo: view.centerYAnchor),

      iconView.topAnchor.constraint(equalTo: card.contentView.topAnchor, constant: DOLSpacing.xl),
      iconView.centerXAnchor.constraint(equalTo: card.contentView.centerXAnchor),
      iconView.heightAnchor.constraint(equalToConstant: 48),
      iconView.widthAnchor.constraint(equalToConstant: 48),

      titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: DOLSpacing.md),
      titleLabel.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: DOLSpacing.lg),
      titleLabel.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -DOLSpacing.lg),

      bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DOLSpacing.sm),
      bodyLabel.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: DOLSpacing.lg),
      bodyLabel.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -DOLSpacing.lg),

      continueButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: DOLSpacing.lg),
      continueButton.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: DOLSpacing.lg),
      continueButton.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -DOLSpacing.lg),
      continueButton.heightAnchor.constraint(equalToConstant: 50),
      continueButton.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor, constant: -DOLSpacing.xl),
    ])

    bodyLabel.textAlignment = .center
    titleLabel.textAlignment = .center
  }

  @objc private func continuePressed() {
    UISelectionFeedbackGenerator().selectionChanged()
    navigationController?.popViewController(animated: true)
  }
}
