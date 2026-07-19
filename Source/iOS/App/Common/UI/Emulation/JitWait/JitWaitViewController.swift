// Copyright 2022 DolphiniOS Project
// SPDX-License-Identifier: GPL-2.0-or-later

import UIKit

// Tier 1 "classic" programmatic replacement for JitWait.xib. Same content,
// same behavior (timer-driven JIT re-check, error alert, three actions) —
// only the construction and visual styling changed.
class JitWaitViewController: UIViewController {
  @objc weak var delegate: JitWaitViewControllerDelegate?

  var timer: Timer?
  var isShowingError: Bool = false

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = DOLColor.backgroundPrimary
    layOutContent()

    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkJit), userInfo: nil, repeats: true)

    JitManager.shared().acquireJitByAltServer()
    JitManager.shared().acquireJitByJitStreamer()
  }

  override func viewWillAppear(_ animated: Bool) {
    showAcquisitionErrorIfNecessary()
  }

  @objc func checkJit() {
    if isShowingError {
      return
    }

    let manager = JitManager.shared()
    manager.recheckIfJitIsAcquired()

    if manager.acquiredJit {
      timer?.invalidate()
      delegate?.didFinishJitScreen(result: .jitAcquired, sender: self)
      return
    }

    showAcquisitionErrorIfNecessary()
  }

  func showAcquisitionErrorIfNecessary() {
    let manager = JitManager.shared()

    if let error = manager.acquisitionError {
      manager.acquisitionError = nil
      isShowingError = true

      let alertController = UIAlertController(title: DOLCoreLocalizedString("Error"), message: error, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: DOLCoreLocalizedString("OK"), style: .default, handler: { _ in
        self.isShowingError = false
      }))

      present(alertController, animated: true, completion: nil)
    }
  }

  @objc func helpPressed(_ sender: Any) {
    let url = URL(string: "https://dolphinios.oatmealdome.me/jit-help")
    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
  }

  @objc func noJitPressed(_ sender: Any) {
    timer?.invalidate()
    delegate?.didFinishJitScreen(result: .noJitRequested, sender: self)
  }

  @objc func cancelPressed(_ sender: Any) {
    timer?.invalidate()
    delegate?.didFinishJitScreen(result: .cancel, sender: self)
  }

  private func layOutContent() {
    let iconView = UIImageView(image: UIImage(systemName: "bolt.fill"))
    iconView.tintColor = DOLColor.accentSolid
    iconView.contentMode = .scaleAspectFit
    iconView.translatesAutoresizingMaskIntoConstraints = false

    let titleLabel = UILabel()
    titleLabel.text = "Waiting for JIT"
    titleLabel.font = DOLTypography.display
    titleLabel.textColor = DOLColor.textPrimary
    titleLabel.textAlignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    let bodyLabel = UILabel()
    bodyLabel.text = """
    DolphiniOS is waiting for a remote debugger to connect before emulation can start.

    The Dolphin core uses a technique known as "JIT" to emulate the GameCube and Wii's CPU at fast speeds.

    Apple does not allow JIT to be used on iOS by default. However, by attaching a debugger, iOS will allow JIT to be used.

    For more information, tap "Help".
    """
    bodyLabel.font = DOLTypography.body
    bodyLabel.textColor = DOLColor.textSecondary
    bodyLabel.textAlignment = .center
    bodyLabel.numberOfLines = 0
    bodyLabel.translatesAutoresizingMaskIntoConstraints = false

    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(bodyLabel)

    let helpButton = makeButton(title: "Help", backgroundColor: DOLColor.accentSolid, action: #selector(helpPressed))
    let noJitButton = makeButton(title: "Use No JIT Mode (Slow)", backgroundColor: .systemOrange, action: #selector(noJitPressed))
    let cancelButton = makeButton(title: "Cancel", backgroundColor: DOLColor.destructive, action: #selector(cancelPressed))

    let buttonStack = UIStackView(arrangedSubviews: [helpButton, noJitButton, cancelButton])
    buttonStack.axis = .vertical
    buttonStack.spacing = DOLSpacing.sm
    buttonStack.distribution = .fillEqually
    buttonStack.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(iconView)
    view.addSubview(titleLabel)
    view.addSubview(scrollView)
    view.addSubview(buttonStack)

    NSLayoutConstraint.activate([
      iconView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: DOLSpacing.lg),
      iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      iconView.heightAnchor.constraint(equalToConstant: 72),
      iconView.widthAnchor.constraint(equalToConstant: 72),

      titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: DOLSpacing.md),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DOLSpacing.lg),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DOLSpacing.lg),

      scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DOLSpacing.lg),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -DOLSpacing.lg),

      bodyLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      bodyLabel.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
      bodyLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: DOLSpacing.lg),
      bodyLabel.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -DOLSpacing.lg),
      bodyLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -(DOLSpacing.lg * 2)),

      buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DOLSpacing.lg),
      buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DOLSpacing.lg),
      buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -DOLSpacing.lg),
    ])
  }

  private func makeButton(title: String, backgroundColor: UIColor, action: Selector) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = DOLTypography.headline
    button.backgroundColor = backgroundColor
    button.layer.cornerRadius = DOLRadius.md
    button.layer.cornerCurve = .continuous
    button.heightAnchor.constraint(equalToConstant: 45).isActive = true
    button.addTarget(self, action: action, for: .touchUpInside)
    return button
  }
}
