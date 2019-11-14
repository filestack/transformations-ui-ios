//
//  TransformsToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

@objc public protocol ModuleToolbarDelegate: class {
    func toolbarItemSelected(sender: UIButton)
}

public class ModuleToolbar: EditorToolbar {
    weak var delegate: ModuleToolbarDelegate?

    private var innerToolbar = ArrangeableToolbar()
    private let commands: [EditorModuleCommand]

    // MARK: - Lifecycle Functions

    public required init(commands: [EditorModuleCommand]) {
        self.commands = commands
        super.init()
        setup()
    }

    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Misc Overrides

    public override func setItems(_ items: [UIView] = []) {
        innerToolbar = ArrangeableToolbar(items: items)
        innerToolbar.spacing = Constants.toolbarSpacing

        super.setItems([UIView(), innerToolbar, UIView()])
    }
}

private extension ModuleToolbar {
    func setup() {
        distribution = .equalCentering
        setItems(commands.enumerated().compactMap { commandButton(using: $0.element.icon, tag: $0.offset) })
    }

    func commandButton(using image: UIImage, tag: Int) -> UIButton {
        let button = self.button(using: image)

        button.tintColor = Constants.iconColor
        button.addTarget(delegate, action: #selector(ModuleToolbarDelegate.toolbarItemSelected), for: .touchUpInside)
        button.tag = tag

        return button
    }
}
