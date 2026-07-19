// Copyright 2026 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation
import UIKit

// Tier 1 "classic" programmatic replacement for GraphicsSettings.storyboard's
// root scene. Same 4 rows (General/Enhancements/Hacks/Advanced), same push
// navigation. Unlike Settings/Config's root menus, this one has real C++
// coupling of its own: the original Objective-C++ GraphicsRootViewController
// called VideoBackendBase::PopulateBackendInfo on load — the app's only call
// site, load-bearing for GraphicsAdvancedViewController's backend-capability
// rows. That call moved to GraphicsBackendInfoBridge (Obj-C, bridged) since
// Swift can't call C++ directly here (no C++ interop enabled in this
// project) — see GraphicsBackendInfoBridge.h/.mm.
//
// The 4 destination screens stay Objective-C++ and storyboard-driven —
// tightly coupled to Dolphin's C++ Config:: system, out of scope for this
// pass, same reasoning as Config's leaves.
final class GraphicsRootViewController: UITableViewController {
  private static let cellReuseIdentifier = "GraphicsRootCell"

  private let rows: [(title: String, storyboardIdentifier: String)] = [
    (NSLocalizedString("General", comment: "Graphics row"), "GraphicsGeneralViewController"),
    (NSLocalizedString("Enhancements", comment: "Graphics row"), "GraphicsEnhancementsViewController"),
    (NSLocalizedString("Hacks", comment: "Graphics row"), "GraphicsHacksViewController"),
    (NSLocalizedString("Advanced", comment: "Graphics row"), "GraphicsAdvancedViewController"),
  ]

  convenience init() {
    self.init(style: .insetGrouped)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = NSLocalizedString("Graphics", comment: "Graphics screen title")
    view.backgroundColor = DOLColor.backgroundPrimary

    GraphicsBackendInfoBridge.populateBackendInfo()
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
    let viewController = UIStoryboard(name: "GraphicsSettings", bundle: nil)
      .instantiateViewController(withIdentifier: identifier)
    navigationController?.pushViewController(viewController, animated: true)
  }
}
