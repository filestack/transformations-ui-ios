//
//  TitleToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 08/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

@objc protocol TitleToolbarDelegate: AnyObject {
    func saveSelected(sender: UIButton)
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
        let button = UIButton(type: .system)

        button.titleLabel?.font = Constants.Fonts.semibold(ofSize: Constants.Fonts.navigationFontSize)
        button.setTitle(L18.save.uppercased(), for: .normal)

        button.addTarget(
                delegate,
                action: #selector(TitleToolbarDelegate.saveSelected),
                for: .primaryActionTriggered
        )

        return button
    }

    lazy var undo: UIButton = {
        let button = UIButton(type: .system)

        button.setImage(.fromBundle("icon-undo"), for: .normal)

        button.widthAnchor.constraint(equalToConstant: Constants.Size.toolbarButtonSize.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: Constants.Size.toolbarButtonSize.height).isActive = true

        button.addTarget(
                delegate,
                action: #selector(TitleToolbarDelegate.undoSelected),
                for: .primaryActionTriggered
        )

        return button
    }()

    lazy var redo: UIButton = {
        let button = UIButton(type: .system)

        button.setImage(.fromBundle("icon-redo"), for: .normal)

        button.widthAnchor.constraint(equalToConstant: Constants.Size.toolbarButtonSize.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: Constants.Size.toolbarButtonSize.height).isActive = true

        button.addTarget(
                delegate,
                action: #selector(TitleToolbarDelegate.redoSelected),
                for: .primaryActionTriggered
        )

        return button
    }()

    override init(style: EditorToolbarStyle = .accented) {
        super.init(style: style)

        setup()
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Misc Overrides

    override func setItems(_ items: [UIView] = [], animated: Bool = false) {
        undoRedoToolbar = ArrangeableToolbar(items: [undo, redo])
        undoRedoToolbar.spacing = 16

        innerToolbar = ArrangeableToolbar(items: items)
        innerToolbar.spacing = style.itemSpacing

        saveButtonToolbar = ArrangeableToolbar(items: [saveButton])
        saveButtonToolbar.alignment = .trailing

        super.setItems([undoRedoToolbar, innerToolbar, saveButtonToolbar], animated: animated)
    }
}

private extension TitleToolbar {
    func setup() {
        distribution = .equalCentering
    }
}
