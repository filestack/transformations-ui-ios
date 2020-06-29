//
//  TitleToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 08/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

@objc protocol TitleToolbarDelegate: class {
    func saveSelected(sender: UIButton)
    func cancelSelected(sender: UIButton)
    func undoSelected(sender: UIButton)
    func redoSelected(sender: UIButton)
}

class TitleToolbar: EditorToolbar {
    // MARK: - Internal Properties

    weak var delegate: TitleToolbarDelegate?

    // MARK: - Private Properties

    private var undoRedoToolbar = ArrangeableToolbar()
    private var saveButtonToolbar = ArrangeableToolbar()
    private var innerToolbar = ArrangeableToolbar()

    private var saveButton: UIButton {
        let button = self.button(using: L18.save.uppercased())

        button.setTitleColor(Constants.Color.primaryActionTint, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
        button.addTarget(delegate, action: #selector(TitleToolbarDelegate.saveSelected), for: .touchUpInside)

        return button
    }

    private lazy var cancelButton: UIButton = {
        let button = self.button(using: L18.cancel)

        button.setTitleColor(Constants.Color.defaultTint, for: .normal)
        button.addTarget(delegate, action: #selector(TitleToolbarDelegate.cancelSelected), for: .touchUpInside)

        return button
    }()

    lazy var undo: UIButton = {
        let button = self.button(using: .fromBundle("icon-undo"))

        button.tintColor = Constants.Color.primaryActionTint
        button.addTarget(delegate, action: #selector(TitleToolbarDelegate.undoSelected), for: .touchUpInside)

        return button
    }()

    lazy var redo: UIButton = {
        let button = self.button(using: .fromBundle("icon-redo"))

        button.tintColor = Constants.Color.primaryActionTint
        button.addTarget(delegate, action: #selector(TitleToolbarDelegate.redoSelected), for: .touchUpInside)

        return button
    }()

    // MARK: - Misc Overrides

    override func setItems(_ items: [UIView] = []) {
        shouldAutoAdjustAxis = false

        undoRedoToolbar = ArrangeableToolbar(items: [undo, redo])
        undoRedoToolbar.spacing = style.itemSpacing
        undoRedoToolbar.shouldAutoAdjustAxis = false

        innerToolbar = ArrangeableToolbar(items: items)
        innerToolbar.spacing = style.itemSpacing
        innerToolbar.shouldAutoAdjustAxis = false

        saveButtonToolbar = ArrangeableToolbar(items: [UIView(), saveButton])
        saveButtonToolbar.spacing = 0
        saveButtonToolbar.shouldAutoAdjustAxis = false
        saveButtonToolbar.alignment = .trailing

        super.setItems([undoRedoToolbar, innerToolbar, saveButtonToolbar])
    }
}

extension TitleToolbar {
    override func layoutSubviews() {
        super.layoutSubviews()

        saveButtonToolbar.widthAnchor.constraint(equalTo: undoRedoToolbar.widthAnchor).isActive = true
    }
}
