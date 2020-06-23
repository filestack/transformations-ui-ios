//
//  ModulesToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 07/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

@objc protocol ModulesToolbarDelegate: class {
    func moduleSelected(sender: UIButton)
}

class ModulesToolbar: EditorToolbar {
    weak var delegate: ModulesToolbarDelegate?

    private var innerToolbar = ArrangeableToolbar()
    private var finishButtonWidthConstraint: NSLayoutConstraint?

    // MARK: - Internal Functions

    func moduleButton(using image: UIImage, titled title: String) -> UIButton {
        let button = self.titledImageButton(using: title, image: image)

        button.addTarget(delegate, action: #selector(ModulesToolbarDelegate.moduleSelected), for: .touchUpInside)
        button.tintColor = Constants.Color.icon

        return button
    }

    // MARK: - Misc Overrides

    override func setItems(_ items: [UIView] = []) {
        innerToolbar = ArrangeableToolbar(items: items)
        innerToolbar.spacing = Constants.Spacing.toolbar

        super.setItems([UIView(), innerToolbar, UIView()])
    }
}
