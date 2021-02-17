//
//  EditorToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 08/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

open class EditorToolbar: ArrangeableToolbar {
    // MARK: - Public Properties

    public let style: EditorToolbarStyle

    // MARK: - Overridable Properties

    open override var intrinsicContentSize: CGSize {
        if let height = style.fixedHeight {
            return CGSize(width: UIView.noIntrinsicMetric, height: height)
        } else {
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
    }

    // MARK: - Overridable Functions

    open override func setItems(_ items: [UIView] = [], animated: Bool = false) {
        super.setItems(items, animated: animated)
        setNeedsLayout()
    }

    // MARK: - Lifecycle

    public init(style: EditorToolbarStyle = .default) {
        self.style = style
        super.init()

        setup()
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Open Functions

extension EditorToolbar {
    open func button(using image: UIImage) -> UIButton {
        let button = ToolbarButton(type: .system)

        button.tintColor = style.itemStyle.tintColor
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(delayedStopHighlighting), for: .touchUpInside)
        button.imageCornerRadius = style.itemStyle.cornerRadius

        return button
    }

    open func button(using title: String) -> UIButton {
        let button = ToolbarButton(type: .system)

        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        button.setTitleColor(style.itemStyle.tintColor, for: .normal)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(delayedStopHighlighting), for: .touchUpInside)

        return button
    }

    open func button(using title: String, image: UIImage) -> TitledImageButton {
        let buttonRect = CGRect(origin: .zero, size: Constants.Size.wideToolbarItem)
        let button = TitledImageButton(frame: buttonRect)

        button.tintColor = style.itemStyle.tintColor
        button.spacing = style.itemStyle.spacing
        button.imageCornerRadius = style.itemStyle.cornerRadius
        button.setImage(image, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIFont.smallSystemFontSize)
        button.setTitleColor(style.itemStyle.tintColor, for: .normal)
        button.setTitleColor(style.itemStyle.tintColor?.withAlphaComponent(0.5), for: .disabled)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(delayedStopHighlighting), for: .touchUpInside)

        return button
    }

    open func label(titled title: String) -> UILabel {
        let label = UILabel()

        label.text = title
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        label.tintColor = style.itemStyle.tintColor
        label.textAlignment = style.itemStyle.textAlignment

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
        backgroundColor = style.backgroundColor
        innerInset = style.innerInset
        spacing = style.itemSpacing
        axis = style.axis
        distribution = .equalCentering
    }
}
