//
//  TitleToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 08/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

@objc protocol TitleToolbarDelegate: class {
    func doneSelected(sender: UIButton)
    func cancelSelected(sender: UIButton)
    func undoSelected(sender: UIButton)
    func redoSelected(sender: UIButton)
}

class TitleToolbar: EditorToolbar {
    // MARK: - Internal Properties

    weak var delegate: TitleToolbarDelegate?

    var title: String? {
        didSet {
            if let title = title {
                setItems([label(titled: title.uppercased())])
            } else {
                setItems([])
            }
        }
    }

    var isEditing: Bool = false {
        willSet { removeItem(finishButton) }
        didSet { setItems(items) }
    }

    // MARK: - Private Properties

    private var innerToolbar = ArrangeableToolbar()
    private var finishButtonWidthConstraint: NSLayoutConstraint?

    private lazy var doneButton: UIButton = {
        return button(using: L18.done)
    }()

    private lazy var applyButton: UIButton = {
        return button(using: .fromFrameworkBundle("icon-apply"))
    }()

    private var finishButton: UIButton {
        let button = isEditing ? applyButton : doneButton

        button.tintColor = Constants.doneColor
        button.addTarget(delegate, action: #selector(TitleToolbarDelegate.doneSelected), for: .touchUpInside)

        return button
    }

    private lazy var cancelButton: UIButton = {
        let button = self.button(using: L18.cancel)

        button.tintColor = Constants.cancelColor
        button.addTarget(delegate, action: #selector(TitleToolbarDelegate.cancelSelected), for: .touchUpInside)

        return button
    }()

    lazy var undo: UIButton = {
        let button = self.button(using: .fromFrameworkBundle("icon-undo"))

        button.addTarget(delegate, action: #selector(TitleToolbarDelegate.undoSelected), for: .touchUpInside)
        button.tintColor = Constants.doneColor

        return button
    }()

    lazy var redo: UIButton = {
        let button = self.button(using: .fromFrameworkBundle("icon-redo"))

        button.addTarget(delegate, action: #selector(TitleToolbarDelegate.redoSelected), for: .touchUpInside)
        button.tintColor = Constants.doneColor

        return button
    }()

    // MARK: - Misc Overrides

    override func setItems(_ items: [UIView] = []) {
        shouldAutoAdjustAxis = false

        innerToolbar = ArrangeableToolbar(items: items)
        innerToolbar.spacing = Constants.toolbarSpacing
        innerToolbar.shouldAutoAdjustAxis = false

        super.setItems([cancelButton, undo, innerToolbar, redo, finishButton])
    }
}

extension TitleToolbar {
    override func layoutSubviews() {
        super.layoutSubviews()

        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (_, .regular):
            cancelButton.removeFromSuperview()
            finishButton.removeFromSuperview()
        case (_, .compact):
            insertItem(cancelButton, at: 0)
            addItem(finishButton)
        default:
            break
        }

        if items.contains(finishButton) && items.contains(cancelButton) {
            // Keep the finish button the same width as the cancel button
            finishButton.removeConstraints([finishButtonWidthConstraint].compactMap { $0 })
            finishButtonWidthConstraint = finishButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
            finishButtonWidthConstraint?.isActive = true
        }
    }
}
