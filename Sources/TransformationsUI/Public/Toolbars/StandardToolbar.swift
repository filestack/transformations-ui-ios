//
//  StandardToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TUIKit
import SnapKit

public protocol StandardToolbarDelegate: AnyObject {
    func toolbarItemSelected(toolbar: StandardToolbar, item: DescriptibleEditorItem, control: UIControl)
}

/// `StandardToolbar` represents a toolbar that can contain selectable toolbar items.
public class StandardToolbar: EditorToolbar {
    // MARK: - Public Properties

    public weak var delegate: StandardToolbarDelegate?
    public override var items: [UIView] { innerToolbar.items }
    public let descriptibleItems: [DescriptibleEditorItem]

    public var selectedItem: UIView? {
        didSet {
            if let button = selectedItem as? TUIButton {
                button.isSelected = true
            }
        }
    }

    public var selectedDescriptibleItem: DescriptibleEditorItem? {
        guard let selectedItem = selectedItem else { return nil }
        guard let idx = items.firstIndex(of: selectedItem) else { return nil }

        return descriptibleItems[idx]
    }

    public override var spacing: CGFloat {
        set { innerToolbar.spacing = newValue }
        get { innerToolbar.spacing }
    }

    // MARK: - Private Properties

    private let buttonGroup = TUIButton.Group()
    private lazy var innerToolbar = ArrangeableToolbar()

    // MARK: - Lifecycle

    public required init(items: [DescriptibleEditorItem], style: EditorToolbarStyle = .accented) {
        self.descriptibleItems = items
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
        innerToolbar.innerInsets = style.innerInsets
        innerToolbar.distribution = .fillEqually

        let scrollView = ToolbarScrollView()

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(innerToolbar)
        innerToolbar.snp.makeConstraints { $0.edges.equalTo(scrollView) }

        super.setItems([scrollView], animated: animated)
    }
}

public extension StandardToolbar {
    func setEnabled(item: DescriptibleEditorItem, enabled: Bool) {
        guard let idx = (descriptibleItems.firstIndex { $0 === item }) else { return }

        (items[idx] as? UIButton)?.isEnabled = enabled
    }
}

// MARK: - Actions

private extension StandardToolbar {
    @objc func toolbarItemSelected(sender: UIControl) {
        guard let control = items[sender.tag] as? TUIButton else { return }

        let item = descriptibleItems[sender.tag]

        selectedItem = control
        delegate?.toolbarItemSelected(toolbar: self, item: item, control: control)
    }
}

// MARK: - Private Functions

private extension StandardToolbar {
    func setup() {
        setItems(descriptibleItems.enumerated().compactMap {
            guard let image = $0.element.icon else { return nil }

            let button = TUIButton(type: .custom)

            button.setTitle($0.element.title, for: .normal)
            button.setImage(image, for: .normal)

            button.addTarget(delegate,
                             action: #selector(toolbarItemSelected),
                             for: .primaryActionTriggered)

            button.tag = $0.offset

            button.group = buttonGroup
            button.apply(config: style.buttonConfig)

            return button
        })
    }
}
