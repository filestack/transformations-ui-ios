//
//  DiscardApplyToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 28/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

@objc protocol DiscardApplyToolbarDelegate: class {
    func applySelected(sender: UIButton)
    func discardSelected(sender: UIButton)
}

class DiscardApplyToolbar: EditorToolbar {
    // MARK: - Internal Properties

    weak var delegate: DiscardApplyToolbarDelegate?
    override var items: [UIView] { innerToolbar.items }

    override var spacing: CGFloat {
        set { innerToolbar.spacing = newValue }
        get { innerToolbar.spacing }
    }

    // MARK: - Private Properties

    private lazy var innerToolbar = ArrangeableToolbar()

    // MARK: - Lifecycle

    required init(delegate: DiscardApplyToolbarDelegate? = nil, style: EditorToolbarStyle = .default) {
        self.delegate = delegate
        super.init(style: style)
        setup()
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Misc Overrides

    override func setItems(_ items: [UIView] = []) {
        innerToolbar = ArrangeableToolbar(items: items)
        innerToolbar.spacing = style.itemSpacing

        super.setItems([innerToolbar])
    }
}

private extension DiscardApplyToolbar {
    func setup() {
        let discardButton = button(using: .fromFrameworkBundle("icon-discard"))
        let applyButton = button(using: .fromFrameworkBundle("icon-apply"))

        discardButton.tintColor = style.itemStyle.tintColor
        discardButton.addTarget(delegate, action: #selector(DiscardApplyToolbarDelegate.discardSelected), for: .touchUpInside)

        applyButton.tintColor = Constants.Color.primaryActionTint
        applyButton.addTarget(delegate, action: #selector(DiscardApplyToolbarDelegate.applySelected), for: .touchUpInside)

        setItems([discardButton, UIView(), applyButton])
    }
}

