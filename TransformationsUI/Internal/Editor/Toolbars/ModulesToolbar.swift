//
//  ModulesToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 07/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

@objc protocol ModulesToolbarDelegate: class {
    func doneSelected(sender: UIButton)
    func cancelSelected(sender: UIButton)
    func moduleSelected(sender: UIButton)
}

class ModulesToolbar: EditorToolbar {
    weak var delegate: ModulesToolbarDelegate?

    private var innerToolbar = ArrangeableToolbar()
    private var finishButtonWidthConstraint: NSLayoutConstraint?

    var isEditing: Bool = false {
        willSet { removeItem(finishButton) }
        didSet { setItems(items) }
    }

    private lazy var doneButton: UIButton = {
        return button(using: L18.done)
    }()

    private lazy var applyButton: UIButton = {
        return button(using: .fromFrameworkBundle("icon-apply"))
    }()

    private lazy var cancelButton: UIButton = {
        let button = self.button(using: L18.cancel)

        button.tintColor = Constants.cancelColor
        button.addTarget(delegate, action: #selector(ModulesToolbarDelegate.cancelSelected), for: .touchUpInside)

        return button
    }()

    private var finishButton: UIButton {
        let button = isEditing ? applyButton : doneButton

        button.tintColor = Constants.doneColor
        button.addTarget(delegate, action: #selector(ModulesToolbarDelegate.doneSelected), for: .touchUpInside)

        return button
    }

    // MARK: - Internal Functions

    func moduleButton(using image: UIImage) -> UIButton {
        let button = self.button(using: image)

        button.addTarget(delegate, action: #selector(ModulesToolbarDelegate.moduleSelected), for: .touchUpInside)
        button.tintColor = Constants.iconColor

        return button
    }

    // MARK: - Misc Overrides

    override func setItems(_ items: [UIView] = []) {
        innerToolbar = ArrangeableToolbar(items: items)
        innerToolbar.spacing = Constants.toolbarSpacing

        super.setItems([cancelButton, innerToolbar, finishButton])
    }
}

extension ModulesToolbar {
    override func layoutSubviews() {
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (_, .regular):
            cancelButton.isUserInteractionEnabled = true
            finishButton.isUserInteractionEnabled = true
            cancelButton.alpha = 1
            finishButton.alpha = 1
        case (_, .compact):
            cancelButton.isUserInteractionEnabled = false
            finishButton.isUserInteractionEnabled = false
            cancelButton.alpha = 0
            finishButton.alpha = 0
        default:
            break
        }

        if items.contains(finishButton) && items.contains(cancelButton) {
            finishButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor).isActive = true
        }

        super.layoutSubviews()
    }
}
