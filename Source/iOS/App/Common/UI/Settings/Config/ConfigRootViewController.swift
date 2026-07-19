// Copyright 2026 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation
import UIKit

// Tier 1 "classic" programmatic replacement for ConfigSettings.storyboard's
// root scene (which previously had no backing class at all — pure static
// IB cells + segues). The six destination screens this pushes
// (General/Interface/Audio/GameCube/Wii/Advanced) are still fully
// storyboard/Objective-C++-driven — they're tightly coupled to Dolphin's
// C++ Config:: system, so they stay Obj-C++ for this pass rather than
// attempting a Swift rewrite of that coupling. Only the root menu itself
// (a plain 6-row disclosure list, no C++ coupling of its own) goes
// programmatic + design-system styled.
final class ConfigRootViewController: UITableViewController {
  private static let cellReuseIdentifier = "ConfigRootCell"

  private let rows: [(title: String, storyboardIdentifier: String)] = [
    (NSLocalizedString("General", comment: "Config row"), "ConfigGeneralViewController"),
    (NSLocalizedString("Interface", comment: "Config row"), "ConfigInterfaceViewController"),
    (NSLocalizedString("Audio", comment: "Config row"), "ConfigSoundViewController"),
    (NSLocalizedString("GameCube", comment: "Config row"), "ConfigGameCubeViewController"),
    (NSLocalizedString("Wii", comment: "Config row"), "ConfigWiiViewController"),
    (NSLocalizedString("Advanced", comment: "Config row"), "ConfigAdvancedViewController"),
  ]

  convenience init() {
    self.init(style: .insetGrouped)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = NSLocalizedString("Config", comment: "Config screen title")
    view.backgroundColor = DOLColor.backgroundPrimary
  }

  override func numberOfSections(in tableView: UITableView) -> Int { 1 }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    rows.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellReuseIdentifier)
      ?? UITableViewCell(style: .default, reuseIdentifier: Self.cellReuseIdentifier)

    cell.backgroundColor = DOLColor.backgroundSecondary
    cell.textLabel?.font = DOLTypography.body
    cell.textLabel?.textColor = DOLColor.textPrimary
    cell.textLabel?.text = rows[indexPath.row].title
    cell.accessoryType = .disclosureIndicator

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let identifier = rows[indexPath.row].storyboardIdentifier
    let viewController = UIStoryboard(name: "ConfigSettings", bundle: nil)
      .instantiateViewController(withIdentifier: identifier)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
