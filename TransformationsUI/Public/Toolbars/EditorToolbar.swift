//
//  EditorToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 08/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

open class EditorToolbar: ArrangeableToolbar {
    // MARK: - Overridable Functions

    open func setItems(_ items: [UIView] = []) {
        removeAllItems()

        for item in items {
            addItem(item)
        }

        setNeedsLayout()
    }

    // MARK: - Lifecycle

    public override init() {
        super.init()

        setup()
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Open Functions

extension EditorToolbar {
    open func button(using image: UIImage, type: UIButton.ButtonType = .system) -> UIButton {
        let button = UIButton(type: type)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(delayedStopHighlighting), for: .touchUpInside)

        return button
    }

    open func button(using title: String, type: UIButton.ButtonType = .system) -> UIButton {
        let button = UIButton(type: type)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(delayedStopHighlighting), for: .touchUpInside)

        return button
    }

    open func titledImageButton(using title: String, image: UIImage, type: UIButton.ButtonType = .system) -> UIButton {
        let buttonRect = CGRect(origin: .zero, size: Constants.Size.toolbar)
        let button = TitledImageButton(frame: buttonRect)

        button.padding = 0
        button.setImage(image, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIFont.smallSystemFontSize)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(delayedStopHighlighting), for: .touchUpInside)

        return button
    }

    open func label(titled title: String, tintColor: UIColor = Constants.Color.label, textAlignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()

        label.text = title
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        label.tintColor = tintColor
        label.textAlignment = textAlignment

        return label
    }
}

// MARK: - Actions

private extension EditorToolbar {
    @objc func delayedStopHighlighting(sender: UIButton) {
        DispatchQueue.main.async {
            sender.isHighlighted = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.125) {
            sender.isHighlighted = false
        }
    }
}

// MARK: - Private Functions

private extension EditorToolbar {
    func setup() {
        innerInset = Constants.Spacing.toolbarInset
        distribution = .equalSpacing
    }
}
