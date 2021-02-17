//
//  ResizeViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 12/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

protocol ResizeViewControllerDelegate: class {
    func resizeViewControllerDismissed(with size:CGSize)
}

private enum SizeDimension {
    case width
    case height
    case both
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

    private func label(titled title: String) -> UILabel {
        let label = UILabel()

        label.text = title
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)

        return label
    }

    private lazy var labelsStackView = UIStackView(arrangedSubviews: [
        label(titled: "Width"),
        label(titled: "Height"),
        label(titled: "Lock ratio")
    ])

    private lazy var controlsStackView = UIStackView(arrangedSubviews: [
        widthTextfield, heightTextfield, lockRatioSwitch
    ])

    private lazy var stackView = UIStackView(arrangedSubviews: [
        labelsStackView, controlsStackView
    ])

    private lazy var widthTextfield: UITextField = {
        let textField = UITextField()

        textField.placeholder = "width"
        textField.textAlignment = .right
        textField.borderStyle = .roundedRect
        textField.delegate = self

        return textField
    }()

    private lazy var heightTextfield: UITextField = {
        let textField = UITextField()

        textField.placeholder = "height"
        textField.textAlignment = .right
        textField.borderStyle = .roundedRect
        textField.delegate = self

        return textField
    }()

    private lazy var lockRatioSwitch: UISwitch = {
        let control = UISwitch()

        control.addTarget(self, action: #selector(lockRatioSwitchChanged), for: .valueChanged)
        control.isOn = true

        return control
    }()

    private var allowEndEditing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        allowEndEditing = true

        super.dismiss(animated: flag, completion: completion)
    }

    // MARK: - Actions

    @objc func applySelected(sender: UIButton) {
        dismiss(animated: true) {
            if self.outputImageSize.width > 0 && self.outputImageSize.height > 0 {
                self.delegate?.resizeViewControllerDismissed(with: self.outputImageSize)
            }
        }
    }

    @objc func cancelSelected(sender: UIButton) {
        dismiss(animated: true)
    }

    @objc func lockRatioSwitchChanged(sender: UISwitch) {
        if lockRatioSwitch.isOn {
            enforceOutputSizeRatio()
        }
    }
}

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

private extension ResizeViewController {
    func setup() {
        setupNavigationItems()
        setupViews()
    }

    func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancelSelected))

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(applySelected))
    }

    func setupViews() {
        view.backgroundColor = Constants.Color.background

        labelsStackView.axis = .vertical
        labelsStackView.spacing = 6
        labelsStackView.distribution = .equalSpacing

        controlsStackView.axis = .vertical
        controlsStackView.spacing = 6
        controlsStackView.alignment = .trailing
        controlsStackView.distribution = .equalSpacing

        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.distribution = .fill

        let containingStackView = UIStackView(arrangedSubviews: [UIView(), stackView, UIView()])
        containingStackView.axis = .horizontal
        containingStackView.distribution = .equalSpacing

        widthTextfield.widthAnchor.constraint(equalToConstant: 80).isActive = true
        heightTextfield.widthAnchor.constraint(equalToConstant: 80).isActive = true

        view.fill(with: containingStackView,
                  connectingEdges: [.left, .right, .top],
                  inset: 22,
                  withSafeAreaRespecting: true,
                  activate: true)
    }
}
