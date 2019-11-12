//
//  TransformsToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

@objc protocol TransformsToolbarDelegate: class {
    func rotateSelected(sender: UIButton)
    func cropSelected(sender: UIButton)
    func circleSelected(sender: UIButton)
}

class TransformsToolbar: EditorToolbar {
    weak var delegate: TransformsToolbarDelegate?

    private var innerToolbar = ArrangeableToolbar()

    lazy var rotate: UIButton = {
        let button = self.button(using: .fromFrameworkBundle("icon-rotate"))

        button.tintColor = Constants.iconColor
        button.addTarget(delegate, action: #selector(TransformsToolbarDelegate.rotateSelected), for: .touchUpInside)

        return button
    }()

    lazy var crop: UIButton = {
        let button = self.button(using: .fromFrameworkBundle("icon-crop"))

        button.tintColor = Constants.iconColor
        button.addTarget(delegate, action: #selector(TransformsToolbarDelegate.cropSelected), for: .touchUpInside)

        return button
    }()

    lazy var circle: UIButton = {
        let button = self.button(using: .fromFrameworkBundle("icon-circle"))

        button.tintColor = Constants.iconColor
        button.addTarget(delegate, action: #selector(TransformsToolbarDelegate.circleSelected), for: .touchUpInside)

        return button
    }()

    var isEditing: Bool = false {
        didSet { setup() }
    }

    // MARK: - Lifecycle Functions

    override init() {
        super.init()

        setup()
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Misc Overrides

    public override func setItems(_ items: [UIView] = []) {
        innerToolbar = ArrangeableToolbar(items: items)
        innerToolbar.spacing = Constants.toolbarSpacing

        super.setItems([UIView(), innerToolbar, UIView()])
    }
}

private extension TransformsToolbar {
    func setup() {
        distribution = .equalCentering
        setItems([rotate, crop, circle])
    }
}
