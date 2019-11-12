//
//  EditorToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 08/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

open class EditorToolbar: ArrangeableToolbar {
    // MARK: - Lifecycle Functions

    public override init() {
        super.init()

        setup()
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Functions

    public func button(using image: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)

        return button
    }

    public func button(using title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        button.setTitle(title, for: .normal)

        return button
    }

    public func label(titled title: String) -> UILabel {
        let label = UILabel()

        label.text = title
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        label.tintColor = Constants.labelColor
        label.textAlignment = .center

        return label
    }

    public func setItems(_ items: [UIView] = []) {
        removeAllItems()

        for item in items {
            addItem(item)
        }

        setNeedsLayout()
    }
}

private extension EditorToolbar {
    func setup() {
        innerInset = Constants.toolbarInnerInset
        distribution = .equalSpacing
    }
}
