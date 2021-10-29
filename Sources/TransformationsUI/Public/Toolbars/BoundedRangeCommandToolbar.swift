//
//  BoundedRangeCommandToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 26/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

public protocol BoundedRangeCommandToolbarDelegate: AnyObject {
    func toolbarSliderChanged(slider: UISlider, for command: BoundedRangeCommand)
    func toolbarSliderFinishedChanging(slider: UISlider, for command: BoundedRangeCommand)
}

public class BoundedRangeCommandToolbar: EditorToolbar {
    // MARK: - Public Properties

    public weak var delegate: BoundedRangeCommandToolbarDelegate?

    public var command: BoundedRangeCommand {
        didSet { setupCommand() }
    }

    // MARK: - Private Properties

    private var sliders: [UISlider] = []
    private var valueLabels: [UILabel] = []

    // MARK: - Lifecycle

    public init(command: BoundedRangeCommand, style: EditorToolbarStyle = .accented) {
        self.command = command

        super.init(style: style)

        setupCommand()
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension BoundedRangeCommandToolbar {
    func updateValue(value: Double, at index: Int = 0) {
        guard index < sliders.count else { return }

        let slider = sliders[index]

        slider.value = Float(value)

        DispatchQueue.main.async {
            self.updateValueLabel(for: slider)
        }
    }
}

private extension BoundedRangeCommandToolbar {
    @objc func sliderChanged(_ sender: UISlider) {
        delegate?.toolbarSliderChanged(slider: sender, for: command)
        updateValueLabel(for: sender)
    }

    @objc func sliderFinishedChanging(_ sender: UISlider) {
        delegate?.toolbarSliderFinishedChanging(slider: sender, for: command)
    }

    @objc func sliderDoubleTapped(_ sender: UISlider) {
        sender.setValue(Float(command.defaultValue), animated: true)
    }
}

private extension BoundedRangeCommandToolbar {
    func updateValueLabel(for slider: UISlider) {
        if let label = valueLabel(at: slider.tag) {
            label.text = command.formattedString(using: Double(slider.value))
        }
    }

    func valueLabel(at index: Int) -> UILabel? {
        guard index < valueLabels.count else { return nil }

        return valueLabels[index]
    }

    func createTitleLabel(using title: String) -> UILabel {
        let label = UILabel()

        label.text = title
        label.textAlignment = .center
        label.font = Constants.Fonts.bold(ofSize: UIFont.smallSystemFontSize)
        label.widthAnchor.constraint(equalToConstant: 100).isActive = true

        return label
    }

    func createValueLabel(for command: BoundedRangeCommand) -> UILabel {
        let label = UILabel()

        label.text = command.formattedString(using: command.defaultValue)
        label.textAlignment = .center
        label.font = Constants.Fonts.bold(ofSize: UIFont.smallSystemFontSize)
        label.widthAnchor.constraint(equalToConstant: 100).isActive = true

        return label
    }

    func createSlider(for command: BoundedRangeCommand, index: Int, title: String) -> UISlider {
        let slider = UISlider()

        slider.tintColor = Constants.Color.accent
        slider.minimumValue = Float(command.range.lowerBound)
        slider.maximumValue = Float(command.range.upperBound)
        slider.value = Float(command.defaultValue)
        slider.accessibilityLabel = title
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderFinishedChanging), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderDoubleTapped), for: .touchDownRepeat)
        slider.tag = index

        return slider
    }

    func setupCommand() {
        var items: [UIView] = []
        var valueLabels: [UILabel] = []
        var sliders: [UISlider] = []

        // Generate array of stack views, each containing: [ titleLabel ] - [ slider ] - [ valueLabel ]
        for (idx, title) in command.componentLabels.enumerated() {
            let stackView = UIStackView()

            stackView.axis = .horizontal
            stackView.spacing = 6

            let titleLabel = createTitleLabel(using: title)
            let slider = createSlider(for: command, index: idx, title: title)
            let valueLabel = createValueLabel(for: command)

            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(slider)
            stackView.addArrangedSubview(valueLabel)

            items.append(stackView)
            valueLabels.append(valueLabel)
            sliders.append(slider)
        }

        // Keep a copy of our value labels and sliders so we can easily access them later by index.
        self.valueLabels = valueLabels
        self.sliders = sliders

        // Update items using the newly generated ones.
        setItems(items, animated: true)
    }
}
