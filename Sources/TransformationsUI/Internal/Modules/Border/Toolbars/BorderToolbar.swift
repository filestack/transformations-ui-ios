//
//  BorderToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 10/08/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import UberSegmentedControl

public protocol BorderToolbarDelegate: class {
    func borderToolbarWidthButtonTapped(_ toolbar: BorderToolbar)
    func borderToolbarOpacityButtonTapped(_ toolbar: BorderToolbar)
    func borderToolbarColorButtonTapped(_ toolbar: BorderToolbar)
}

public class BorderToolbar: EditorToolbar {
    private typealias Commands = Modules.Border.Commands

    // MARK: - Public Properties

    public weak var delegate: BorderToolbarDelegate?

    public var color: UIColor? {
        didSet { colorControl?.color = color }
    }

    private(set) var widthControl: UberSegmentedControl?
    private(set) var opacityControl: UberSegmentedControl?
    private(set) var colorControl: RingButton?

    // MARK: - Private Properties

    private lazy var innerStackView: ArrangeableToolbar? = nil
    private let commands: [EditorModuleCommand]
    private var shouldSetupScrollViewItems: Bool = false
    private var controlCommandMap = [UberSegmentedControl: EditorModuleCommand]()

    // MARK: - Lifecycle

    public required init(commands: [EditorModuleCommand], style: EditorToolbarStyle = .default) {
        self.commands = commands

        super.init(style: style)

        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Misc Overrides

    public override func setItems(_ items: [UIView] = [], animated: Bool = false) {
        // NO-OP
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        innerStackView?.setNeedsLayout()
    }

    // MARK: - Actions

    @objc func controlSelected(_ sender: UberSegmentedControl) {
        switch sender {
        case widthControl:
            opacityControl?.selectedSegmentIndex = UberSegmentedControl.noSegment
            delegate?.borderToolbarWidthButtonTapped(self)
        case opacityControl:
            widthControl?.selectedSegmentIndex = UberSegmentedControl.noSegment
            delegate?.borderToolbarOpacityButtonTapped(self)
        case colorControl:
            delegate?.borderToolbarColorButtonTapped(self)
        default:
            assertionFailure("Not implemented")
        }
    }
}

public extension BorderToolbar {
    var selectedDescriptibleItem: DescriptibleEditorItem? {
        if let control = widthControl, control.selectedSegmentIndex == .zero {
            return controlCommandMap[control]
        }

        if let control = opacityControl, control.selectedSegmentIndex == .zero {
            return controlCommandMap[control]
        }

        return nil
    }
}

private extension BorderToolbar {
    func setup() {
        shouldAutoAdjustAxis = false
        axis = .vertical
        innerInset = 0
        distribution = .equalCentering

        let commandItems: [UIView] = (commands.enumerated().compactMap { offset, command in
            switch command {
            case is Commands.Width:
                let control = UberSegmentedControl(items: ["Width"])

                control.addTarget(self, action: #selector(controlSelected), for: .valueChanged)

                widthControl = control
                controlCommandMap[control] = command

                return control
            case is Commands.Opacity:
                let control = UberSegmentedControl(items: ["Opacity"])

                control.addTarget(self, action: #selector(controlSelected), for: .valueChanged)

                opacityControl = control
                controlCommandMap[control] = command

                return control
            case is Commands.Color:
                let control = RingButton()

                control.addTarget(self, action: #selector(controlSelected), for: .touchUpInside)

                colorControl = control

                return control
            default:
                return nil
            }
        })

        let stackView = ArrangeableToolbar(items: commandItems)

        stackView.axis = .horizontal
        stackView.spacing = style.itemSpacing
        stackView.distribution = .equalSpacing
        stackView.innerInset = style.innerInset
        stackView.translatesAutoresizingMaskIntoConstraints = false

        innerStackView = stackView

        let scrollView = ToolbarScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        stackView.centerXAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerYAnchor).isActive = true

        super.setItems([scrollView])
    }
}
