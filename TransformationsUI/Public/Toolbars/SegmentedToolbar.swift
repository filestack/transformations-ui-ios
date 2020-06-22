//
//  SegmentedToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 28/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

@objc public protocol SegmentedToolbarDelegate: class {
    func segmentedToolbarItemSelected(sender: UISegmentedControl)
}

public class SegmentedToolbar: EditorToolbar {
    // MARK: - Public Properties

    public weak var delegate: SegmentedToolbarDelegate?

    public override var items: [UIView] {
        return innerToolbar.items
    }

    // MARK: - Private Properties

    private lazy var innerToolbar = ArrangeableToolbar()
    private let commands: [EditorModuleCommand]
    private let buttonType: UIButton.ButtonType
    private let segmentedControl: UISegmentedControl

    // MARK: - Lifecycle Functions

    public required init(commands: [EditorModuleCommand], buttonType: UIButton.ButtonType = .system) {
        self.commands = commands
        self.buttonType = buttonType
        self.segmentedControl = UISegmentedControl(items: commands.enumerated().compactMap { $0.element.title })

        super.init()
        setup()
    }

    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func resetSelectedSegment(to index: Int = 0) {
        segmentedControl.selectedSegmentIndex = index
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

private extension SegmentedToolbar {
    func setup() {
        distribution = .equalCentering
        resetSelectedSegment()

        segmentedControl.addTarget(delegate,
                                   action: #selector(SegmentedToolbarDelegate.segmentedToolbarItemSelected),
                                   for: .valueChanged)

        setItems([segmentedControl])
    }
}
