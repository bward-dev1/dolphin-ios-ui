// Copyright 2022 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation
import UIKit

// Tier 1 "classic" programmatic replacement for SettingsRoot.storyboard's
// static table. Same three sections/rows and the same navigation behavior
// as before — only the construction (programmatic vs. Interface Builder)
// and visual styling (design-system tokens) changed. Of the five
// destination screens this pushes/presents, About is now programmatic too;
// Config/Graphics/Controllers/Debug are still storyboard-driven — converting
// those is future Settings-tree work, out of scope for this pass.
private enum SettingsRow {
  case info(title: String, value: () -> String)
  case link(title: String, action: () -> Void)
  case navigation(title: String, action: () -> Void)
}

private struct SettingsSection {
  let rows: [SettingsRow]
}

class SettingsRootViewController: UITableViewController {
  private static let cellReuseIdentifier = "SettingsRootCell"

  private lazy var sections: [SettingsSection] = [
    SettingsSection(rows: [
      .info(title: NSLocalizedString("Version", comment: "Settings row"), value: {
        VersionManager.shared().appVersion.userFacing
      }),
      .info(title: NSLocalizedString("Dolphin Core", comment: "Settings row"), value: {
        VersionManager.shared().coreVersion
      }),
      .navigation(title: NSLocalizedString("About", comment: "Settings row"), action: { [weak self] in
        self?.presentAboutSettings()
      }),
      .link(title: NSLocalizedString("Help", comment: "Settings row"), action: {
        UIApplication.shared.open(URL(string: "https://oatmealdome.me/dolphinios/")!)
      }),
    ]),
    SettingsSection(rows: [
      .navigation(title: NSLocalizedString("Config", comment: "Settings row"), action: { [weak self] in
        self?.navigationController?.pushViewController(ConfigRootViewController(), animated: true)
      }),
      .navigation(title: NSLocalizedString("Graphics", comment: "Settings row"), action: { [weak self] in
        self?.navigationController?.pushViewController(GraphicsRootViewController(), animated: true)
      }),
      .navigation(title: NSLocalizedString("Controllers", comment: "Settings row"), action: { [weak self] in
        self?.pushSettingsStoryboard(named: "ControllersSettings")
      }),
      .navigation(title: NSLocalizedString("Cover Art", comment: "Settings row"), action: { [weak self] in
        self?.navigationController?.pushViewController(CoverArtSettingsViewController(), animated: true)
      }),
      .navigation(title: NSLocalizedString("App Icon", comment: "Settings row"), action: { [weak self] in
        self?.navigationController?.pushViewController(AppIconSelectorViewController(), animated: true)
      }),
      .navigation(title: NSLocalizedString("Optimize My Settings", comment: "Settings row"), action: { [weak self] in
        self?.navigationController?.pushViewController(OptimizeSettingsViewController(), animated: true)
      }),
    ]),
    SettingsSection(rows: [
      .navigation(title: NSLocalizedString("Debug", comment: "Settings row"), action: { [weak self] in
        self?.navigationController?.pushViewController(DebugRootViewController(), animated: true)
      }),
    ]),
  ]

  convenience init() {
    self.init(style: .insetGrouped)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = NSLocalizedString("Settings", comment: "Settings screen title")
    view.backgroundColor = DOLColor.backgroundPrimary
    // Not using register(_:forCellReuseIdentifier:) here — class-based
    // registration always dequeues .default-style cells, whose
    // detailTextLabel is nil, which would silently drop the Version/Dolphin
    // Core row values. Cells are constructed with an explicit style below.
  }

  private func pushSettingsStoryboard(named name: String) {
    guard let viewController = UIStoryboard(name: name, bundle: nil).instantiateInitialViewController() else {
      return
    }
    navigationController?.pushViewController(viewController, animated: true)
  }

  private func presentAboutSettings() {
    present(AboutViewController.makePresentable(), animated: true)
  }

  // MARK: - UITableViewDataSource

  override func numberOfSections(in tableView: UITableView) -> Int {
    sections.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    sections[section].rows.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = sections[indexPath.section].rows[indexPath.row]
    // Every cell for this identifier is created with the same .value1 style
    // (even rows with no detail text) so reused cells never mismatch style —
    // UITableViewCell.CellStyle can't change after creation, and mixing
    // styles under one reuse identifier would make the detail label
    // intermittently disappear depending on which cell got recycled.
    let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellReuseIdentifier)
      ?? UITableViewCell(style: .value1, reuseIdentifier: Self.cellReuseIdentifier)

    cell.backgroundColor = DOLColor.backgroundSecondary
    cell.textLabel?.font = DOLTypography.body
    cell.textLabel?.textColor = DOLColor.textPrimary
    cell.detailTextLabel?.font = DOLTypography.body
    cell.detailTextLabel?.textColor = DOLColor.textSecondary

    switch row {
    case let .info(title, value):
      cell.textLabel?.text = title
      cell.detailTextLabel?.text = value()
      cell.selectionStyle = .none
      cell.accessoryType = .none
    case let .link(title, _):
      cell.textLabel?.text = title
      cell.detailTextLabel?.text = nil
      cell.selectionStyle = .default
      cell.accessoryType = .disclosureIndicator
    case let .navigation(title, _):
      cell.textLabel?.text = title
      cell.detailTextLabel?.text = nil
      cell.selectionStyle = .default
      cell.accessoryType = .disclosureIndicator
    }

    return cell
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    switch sections[indexPath.section].rows[indexPath.row] {
    case .info:
      break
    case let .link(_, action), let .navigation(_, action):
      action()
    }
  }
}
