// Copyright 2026 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

import UIKit

// Tier 1 "classic" programmatic replacement for Main.storyboard's tab bar
// controller. Preserves the same two tabs (Games / Settings) — Games still
// roots into SoftwareList.storyboard, Settings now roots into the fully
// programmatic SettingsRootViewController — with the new glass-simulated
// visual treatment on the shell itself.
final class DOLTabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    applyGlassAppearance()
  }

  static func makeRootTabBarController() -> DOLTabBarController {
    let softwareListStoryboard = UIStoryboard(name: "SoftwareList", bundle: nil)
    let gamesNav = softwareListStoryboard.instantiateViewController(withIdentifier: "softwareListRoot")
    gamesNav.tabBarItem = UITabBarItem(
      title: NSLocalizedString("Games", comment: "Games tab title"),
      image: UIImage(systemName: "square.grid.2x2"),
      selectedImage: UIImage(systemName: "square.grid.2x2.fill")
    )

    let settingsNav = UINavigationController(rootViewController: SettingsRootViewController())
    settingsNav.navigationBar.prefersLargeTitles = true
    settingsNav.tabBarItem = UITabBarItem(
      title: NSLocalizedString("Settings", comment: "Settings tab title"),
      image: UIImage(systemName: "gearshape"),
      selectedImage: UIImage(systemName: "gearshape.fill")
    )

    let tabBarController = DOLTabBarController()
    tabBarController.viewControllers = [gamesNav, settingsNav]
    return tabBarController
  }

  private func applyGlassAppearance() {
    let appearance = UITabBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    appearance.backgroundColor = DOLColor.glassFill

    let itemAppearance = UITabBarItemAppearance()
    itemAppearance.normal.iconColor = DOLColor.textSecondary
    itemAppearance.normal.titleTextAttributes = [
      .foregroundColor: DOLColor.textSecondary,
      .font: DOLTypography.caption,
    ]
    itemAppearance.selected.iconColor = DOLColor.accentSolid
    itemAppearance.selected.titleTextAttributes = [
      .foregroundColor: DOLColor.accentSolid,
      .font: DOLTypography.caption,
    ]
    appearance.stackedLayoutAppearance = itemAppearance
    appearance.inlineLayoutAppearance = itemAppearance
    appearance.compactInlineLayoutAppearance = itemAppearance

    tabBar.standardAppearance = appearance
    tabBar.scrollEdgeAppearance = appearance
    tabBar.tintColor = DOLColor.accentSolid
  }
}
