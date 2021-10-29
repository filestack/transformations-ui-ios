//
//  ResizeViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 12/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import SnapKit

protocol ResizeViewControllerDelegate: AnyObject {
    func resizeViewControllerDismissed(with size: CGSize)
}

class ResizeViewController: UIViewController {
    weak var delegate: ResizeViewControllerDelegate?

    var imageSize: CGSize = .zero {
        didSet {
            lastImageSize = imageSize
            outputImageSize = imageSize
        }
    }

    private var lastImageSize: CGSize = .zero

    private lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()

        numberFormatter.maximumFractionDigits = 1

        return numberFormatter
    }()

    private var outputImageSize: CGSize = .zero {
        didSet {
            widthTextfield.text = numberFormatter.string(from: NSNumber(floatLiteral: Double(outputImageSize.width)))
            heightTextfield.text = numberFormatter.string(from: NSNumber(floatLiteral: Double(outputImageSize.height)))
        }
    }

    private func label(titled title: String, isBold: Bool = false, isCentered: Bool = false) -> UILabel {
        let label = UILabel()
        let fontSize = UIFont.labelFontSize

        label.text = title
        label.font = isBold ? Constants.Fonts.bold(ofSize: fontSize) : Constants.Fonts.default(ofSize: fontSize)
        label.textAlignment = isCentered ? .center : .natural

        return label
    }

    private lazy var widthStackView = UIStackView(arrangedSubviews: [
        label(titled: "Width"),
        widthTextfield
    ])

    private lazy var heightStackView = UIStackView(arrangedSubviews: [
        label(titled: "Height"),
        heightTextfield
    ])

    private lazy var lockRatioStackView = UIStackView(arrangedSubviews: [
        label(titled: "Lock ratio"),
        lockRatioSwitch
    ])

    private lazy var stackView = UIStackView(arrangedSubviews: [
        label(titled: title ?? "", isBold: true, isCentered: true),
        UIView(),
        widthStackView,
        heightStackView,
        lockRatioStackView,
        UIView(),
        actionsStackView,
    ])

    private lazy var actionsStackView = UIStackView(arrangedSubviews: [
        cancelButton,
        applyButton
    ])

    private lazy var widthTextfield: UITextField = {
        let textField = UITextField()

        textField.placeholder = "width"
        textField.textAlignment = .right
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.font = Constants.Fonts.default(ofSize: UIFont.labelFontSize)

        return textField
    }()

    private lazy var heightTextfield: UITextField = {
        let textField = UITextField()

        textField.placeholder = "height"
        textField.textAlignment = .right
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.font = Constants.Fonts.default(ofSize: UIFont.labelFontSize)

        return textField
    }()

    private lazy var lockRatioSwitch: UISwitch = {
        let control = UISwitch()

        control.addTarget(self, action: #selector(lockRatioSwitchChanged), for: .valueChanged)
        control.isOn = true

        return control
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle(L18.cancel, for: .normal)
        button.addTarget(self, action: #selector(cancelSelected(_:)), for: .primaryActionTriggered)
        button.titleLabel?.font = Constants.Fonts.semibold(ofSize: Constants.Fonts.navigationFontSize)
        button.tintColor = Constants.Color.defaultTint

        return button
    }()

    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle("Apply", for: .normal)
        button.addTarget(self, action: #selector(applySelected(_:)), for: .primaryActionTriggered)
        button.titleLabel?.font = Constants.Fonts.semibold(ofSize: Constants.Fonts.navigationFontSize)
        button.tintColor = Constants.Color.accent

        return button
    }()

    private var allowEndEditing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        widthTextfield.becomeFirstResponder()
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        allowEndEditing = true

        super.dismiss(animated: flag, completion: completion)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        Constants.supportedInterfaceOrientations
    }
}

// MARK: - Actions

extension ResizeViewController {
    @objc func applySelected(_ sender: UIButton) {
        dismiss(animated: true) {
            if self.outputImageSize.width > 0 && self.outputImageSize.height > 0 {
                self.delegate?.resizeViewControllerDismissed(with: self.outputImageSize)
            }
        }
    }

    @objc func cancelSelected(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @objc func lockRatioSwitchChanged(_ sender: UISwitch) {
        if lockRatioSwitch.isOn {
            enforceOutputSizeRatio()
        }
    }
}

// MARK: - UITextFieldDelegate Protocol

extension ResizeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let value = CGFloat(numericValue(for: textField))

        switch textField {
        case widthTextfield:
            return updateOutputSize(dimension: .width, value: value)
        case heightTextfield:
            return updateOutputSize(dimension: .height, value: value)
        default:
            return false
        }
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // Don't allow ending editing unless numeric value is >0.
        guard numericValue(for: textField) > 0 || allowEndEditing else { return false }

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let value = CGFloat(numericValue(for: textField))

        switch textField {
        case widthTextfield:
            updateOutputSize(dimension: .width, value: value)
        case heightTextfield:
            updateOutputSize(dimension: .height, value: value)
        default:
            break
        }
    }
}

// MARK: - Private Functions

private extension ResizeViewController {
    func numericValue(for textField: UITextField) -> Double {
        return (numberFormatter.number(from: textField.text ?? "") ?? 0).doubleValue
    }

    @discardableResult func updateOutputSize(dimension: SizeDimension, value: CGFloat) -> Bool {
        // Only allow values >0.
        guard value > 0 else { return false }

        switch dimension {
        case .width:
            // Prevent values larger than `maxImageInputSize.width`
            guard value <= Constants.Size.maxImageInputSize.width else { return false }

            outputImageSize.width = value
        case .height:
            // Prevent values larger than `maxImageInputSize.height`
            guard value <= Constants.Size.maxImageInputSize.height else { return false }

            outputImageSize.height = value
        default:
            return false
        }

        if lockRatioSwitch.isOn {
            enforceOutputSizeRatio(basedOn: dimension)
        }

        return true
    }

    func enforceOutputSizeRatio(basedOn dimension: SizeDimension = .both) {
        defer { lastImageSize = outputImageSize }

        let ratio = imageSize.width / imageSize.height

        switch dimension {
        case .width:
            outputImageSize.height = outputImageSize.width / ratio
        case .height:
            outputImageSize.width = outputImageSize.height * ratio
        case .both:
            outputImageSize.height = outputImageSize.width / ratio
            outputImageSize.width = outputImageSize.height * ratio
        }
    }
}

// MARK: - Private Functions (Setup)

private extension ResizeViewController {
    func setup() {
        title = "Resize Image"
        setupViews()
    }

    func setupViews() {
        preferredContentSize = CGSize(width: 280, height: 260)
        view.backgroundColor = Constants.Color.secondaryBackground

        widthStackView.axis = .horizontal
        widthStackView.alignment = .fill
        widthStackView.distribution = .fill
        widthStackView.spacing = 12

        heightStackView.axis = .horizontal
        heightStackView.alignment = .fill
        heightStackView.distribution = .fill
        heightStackView.spacing = 12

        lockRatioStackView.axis = .horizontal
        lockRatioStackView.alignment = .fill
        lockRatioStackView.spacing = 12
        lockRatioStackView.distribution = .fill

        actionsStackView.axis = .horizontal
        actionsStackView.alignment = .fill
        actionsStackView.distribution = .equalSpacing
        actionsStackView.spacing = 12

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12

        for stackView in [widthStackView, heightStackView, lockRatioStackView] {
            stackView.arrangedSubviews.last?.snp.makeConstraints { $0.width.equalTo(80) }
        }

        let insets = UIEdgeInsets(top: 20, left: 40, bottom: 20, right: 40)

        view.addSubview(stackView)
        stackView.snp.makeConstraints { $0.left.right.top.equalTo(view.safeAreaLayoutGuide).inset(insets) }
    }
}

// MARK: - ResizeViewController.SizeDimension

private extension ResizeViewController {
    enum SizeDimension {
        case width
        case height
        case both
    }
}
