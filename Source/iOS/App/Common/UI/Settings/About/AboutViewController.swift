// Copyright 2026 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

import UIKit

// Tier 1 "classic" programmatic replacement for AboutSettings.storyboard.
// Same static content and the same Source Code / Done actions as before —
// only the construction (programmatic vs. Interface Builder) and visual
// styling (design-system tokens) changed.
final class AboutViewController: UIViewController {
  private let scrollView = UIScrollView()

  static func makePresentable() -> UINavigationController {
    let navigationController = UINavigationController(rootViewController: AboutViewController())
    navigationController.modalPresentationStyle = .formSheet
    return navigationController
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = NSLocalizedString("About Dolphin", comment: "About screen title")
    view.backgroundColor = DOLColor.backgroundPrimary

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .done,
      target: self,
      action: #selector(donePressed)
    )

    layOutContent()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    scrollView.flashScrollIndicators()
  }

  private func layOutContent() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)

    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = DOLSpacing.lg
    stack.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(stack)

    let logoView = UIImageView(image: UIImage(named: "DolphinLogo"))
    logoView.contentMode = .scaleAspectFit
    logoView.translatesAutoresizingMaskIntoConstraints = false
    logoView.heightAnchor.constraint(equalToConstant: 128).isActive = true

    let titleLabel = UILabel()
    titleLabel.text = NSLocalizedString("DolphiniOS", comment: "About screen app name")
    titleLabel.font = DOLTypography.display
    titleLabel.textColor = DOLColor.accentSolid
    titleLabel.textAlignment = .center

    let copyrightLabel = UILabel()
    copyrightLabel.text = NSLocalizedString(
      "© 2003-2015+ Dolphin Team. \n© 2019-2024+ DolphiniOS Project.",
      comment: "About screen copyright notice"
    )
    copyrightLabel.numberOfLines = 0

    let disclaimerLabel = UILabel()
    disclaimerLabel.text = NSLocalizedString(
      "DolphiniOS is an unofficial and separately maintained port of Dolphin to iOS. The DolphiniOS Project has no relation to Dolphin Team.",
      comment: "About screen disclaimer"
    )
    disclaimerLabel.numberOfLines = 0

    let trademarkLabel = UILabel()
    trademarkLabel.text = NSLocalizedString(
      "\u{201C}GameCube\u{201D} and \u{201C}Wii\u{201D} are trademarks of Nintendo. DolphiniOS is not affiliated with Nintendo in any way.",
      comment: "About screen trademark notice"
    )
    trademarkLabel.numberOfLines = 0

    let piracyLabel = UILabel()
    piracyLabel.text = NSLocalizedString(
      "This software should not be used to play games you do not legally own.",
      comment: "About screen piracy notice"
    )
    piracyLabel.numberOfLines = 0

    for label in [copyrightLabel, disclaimerLabel, trademarkLabel, piracyLabel] {
      label.font = DOLTypography.body
      label.textColor = DOLColor.textSecondary
      label.textAlignment = .center
    }

    let sourceCodeButton = UIButton(type: .system)
    sourceCodeButton.setTitle(NSLocalizedString("Source Code", comment: "About screen button"), for: .normal)
    sourceCodeButton.titleLabel?.font = DOLTypography.headline
    sourceCodeButton.setTitleColor(DOLColor.accentSolid, for: .normal)
    sourceCodeButton.addTarget(self, action: #selector(sourceCodePressed), for: .touchUpInside)

    [logoView, titleLabel, copyrightLabel, disclaimerLabel, trademarkLabel, piracyLabel, sourceCodeButton]
      .forEach { stack.addArrangedSubview($0) }

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

      stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: DOLSpacing.lg),
      stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: DOLSpacing.lg),
      stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -DOLSpacing.lg),
      stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -DOLSpacing.lg),
      stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -(DOLSpacing.lg * 2)),
    ])
  }

  @objc private func sourceCodePressed() {
    UIApplication.shared.open(URL(string: "https://github.com/oatmealdome/dolphin-ios/")!)
  }

  @objc private func donePressed() {
    dismiss(animated: true)
  }
}
