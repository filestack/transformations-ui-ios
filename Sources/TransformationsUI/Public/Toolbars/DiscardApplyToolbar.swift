//
//  DiscardApplyToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 27/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

@objc public protocol DiscardApplyToolbarDelegate: AnyObject {
    func applySelected(sender: UIButton?)
    func discardSelected(sender: UIButton?)
}

public class DiscardApplyToolbar: EditorToolbar {
    // MARK: - Internal Properties

    public weak var delegate: DiscardApplyToolbarDelegate?
    public override var items: [UIView] { innerToolbar.items }

    public override var spacing: CGFloat {
        set { innerToolbar.spacing = newValue }
        get { innerToolbar.spacing }
    }

    // MARK: - Private Properties

    private lazy var innerToolbar = ArrangeableToolbar()

    // MARK: - Lifecycle

    public required override init(style: EditorToolbarStyle = .default) {
        super.init(style: style)
        setup()
    }

    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Misc Overrides

    public override func setItems(_ items: [UIView] = [], animated: Bool = false) {
        innerToolbar = ArrangeableToolbar(items: items)
        innerToolbar.spacing = style.itemSpacing

        super.setItems([innerToolbar], animated: animated)
    }
}

private extension DiscardApplyToolbar {
    func setup() {
        let discardButton = button(using: .fromBundle("icon-discard"))
        let applyButton = button(using: .fromBundle("icon-apply"))

        discardButton.tintColor = style.itemStyle.tintColor
        discardButton.addTarget(delegate, action: #selector(DiscardApplyToolbarDelegate.discardSelected), for: .touchUpInside)

        applyButton.tintColor = Constants.Color.primaryActionTint
        applyButton.addTarget(delegate, action: #selector(DiscardApplyToolbarDelegate.applySelected), for: .touchUpInside)

        setItems([discardButton, UIView(), applyButton])
    }
}

