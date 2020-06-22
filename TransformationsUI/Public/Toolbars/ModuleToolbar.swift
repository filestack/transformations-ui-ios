//
//  ModuleToolbar.swift
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
    // MARK: - Public Properties

    public weak var delegate: ModuleToolbarDelegate?

    public override var items: [UIView] {
        return innerToolbar.items
    }

    // MARK: - Private Properties

    private lazy var innerToolbar = ArrangeableToolbar()
    private let commands: [EditorModuleCommand]
    private let buttonType: UIButton.ButtonType

    // MARK: - Lifecycle Functions

    public required init(commands: [EditorModuleCommand], buttonType: UIButton.ButtonType = .system) {
        self.commands = commands
        self.buttonType = buttonType
        super.init()
        setup()
    }

    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Misc Overrides

    public override func setItems(_ items: [UIView] = []) {
        innerToolbar = ArrangeableToolbar(items: items)
        innerToolbar.spacing = Constants.Spacing.toolbar

        let scrollView = ToolbarScrollView()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.fill(with: innerToolbar, activate: true)

        super.setItems([scrollView])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        innerToolbar.setNeedsLayout()
    }
}

private extension ModuleToolbar {
    func setup() {
        distribution = .equalCentering

        setItems(commands.enumerated().compactMap {
            guard let icon = $0.element.icon else { return nil }

            return commandButton(titled: $0.element.title, image: icon, tag: $0.offset)
        })
    }

    func commandButton(titled title: String, image: UIImage, tag: Int) -> UIButton {
        let button = self.titledImageButton(using: title, image: image)

        button.tintColor = Constants.Color.icon
        button.addTarget(delegate, action: #selector(ModuleToolbarDelegate.toolbarItemSelected), for: .touchUpInside)
        button.tag = tag

        return button
    }
}
