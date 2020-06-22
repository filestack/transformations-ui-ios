//
//  DiscardApplyToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 28/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

@objc public protocol DiscardApplyToolbarDelegate: class {
    func discardSelected(sender: UIButton)
    func applySelected(sender: UIButton)
}

public class DiscardApplyToolbar: EditorToolbar {
    // MARK: - Public Properties

    public weak var delegate: DiscardApplyToolbarDelegate?

    public override var items: [UIView] {
        return innerToolbar.items
    }

    // MARK: - Private Properties

    private lazy var innerToolbar = ArrangeableToolbar()

    // MARK: - Lifecycle

    public required init(delegate: DiscardApplyToolbarDelegate? = nil) {
        super.init()
        self.delegate = delegate
        setup()
    }

    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Misc Overrides

    public override func setItems(_ items: [UIView] = []) {
        innerToolbar = ArrangeableToolbar(items: items)
        innerToolbar.spacing = Constants.Spacing.toolbar

        super.setItems([innerToolbar])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        innerToolbar.setNeedsLayout()
    }
}

private extension DiscardApplyToolbar {
    func setup() {
        distribution = .equalCentering

        let discardButton = button(using: .fromFrameworkBundle("icon-discard"))
        let applyButton = button(using: .fromFrameworkBundle("icon-apply"))

        discardButton.tintColor = Constants.Color.cancel
        discardButton.addTarget(delegate, action: #selector(DiscardApplyToolbarDelegate.discardSelected), for: .touchUpInside)

        applyButton.tintColor = Constants.Color.done
        applyButton.addTarget(delegate, action: #selector(DiscardApplyToolbarDelegate.applySelected), for: .touchUpInside)

        setItems([discardButton, UIView(), applyButton])
    }
}

