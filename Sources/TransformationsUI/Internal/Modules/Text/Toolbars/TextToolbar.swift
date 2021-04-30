//
//  TextToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 03/02/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import UberSegmentedControl

public protocol TextToolbarDelegate: AnyObject {
    func textToolbarFontFamilyChanged(_ toolbar: TextToolbar)
    func textToolbarFontColorChanged(_ toolbar: TextToolbar)
    func textToolbarFontStyleChanged(_ toolbar: TextToolbar)
    func textToolbarTextAlignmentChanged(_ toolbar: TextToolbar)
}

public class TextToolbar: EditorToolbar {
    private typealias Commands = Modules.Text.Commands

    // MARK: - Public Properties

    public weak var delegate: TextToolbarDelegate?

    public override var items: [UIView] {
        [
            selectFontStyleControl,
            selectFontColorControl,
            selectFontFamilyControl,
            selectTextAlignmentControl
        ].compactMap { $0 }
    }

    public var fontFamily: String? {
        didSet {
            guard let selectFontFamilyControl = selectFontFamilyControl else { return }

            selectFontFamilyControl.setTitle(fontFamily, forSegmentAt: 0)
        }
    }

    public var fontColor: UIColor? {
        didSet { selectFontColorControl?.color = fontColor }
    }

    public var fontStyle: FontStyle? {
        didSet {
            guard let fontStyle = fontStyle, let selectFontStyleControl = selectFontStyleControl else { return }

            selectFontStyleControl.selectedSegmentIndexes = IndexSet([
                fontStyle.contains(.bold) ? 0 : nil,
                fontStyle.contains(.italic) ? 1 : nil,
                fontStyle.contains(.underline) ? 2 : nil,
            ].compactMap { $0 })
        }
    }

    public var textAlignment: NSTextAlignment? {
        didSet {
            guard let textAlignment = textAlignment else { return }

            selectTextAlignmentControl?.selectedSegmentIndexes = IndexSet([Int(textAlignment.rawValue)])
        }
    }

    private(set) var selectFontFamilyControl: UberSegmentedControl?
    private(set) var selectFontColorControl: RingButton?
    private(set) var selectFontStyleControl: UberSegmentedControl?
    private(set) var selectTextAlignmentControl: UberSegmentedControl?

    // MARK: - Private Properties

    private lazy var innerStackView: ArrangeableToolbar? = nil
    private let commandsInGroups: [[EditorModuleCommand]]
    private var shouldSetupScrollViewItems: Bool = false

    // MARK: - Lifecycle

    public required init(commandsInGroups: [[EditorModuleCommand]], style: EditorToolbarStyle = .default) {
        self.commandsInGroups = commandsInGroups

        super.init(style: style)

        setup()
    }

    public required init(coder _: NSCoder) {
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
        case selectFontFamilyControl:
            delegate?.textToolbarFontFamilyChanged(self)
        case selectFontColorControl:
            delegate?.textToolbarFontColorChanged(self)
        case selectFontStyleControl:
            fontStyle = FontStyle([
                sender.selectedSegmentIndexes.contains(0) ? .bold : nil,
                sender.selectedSegmentIndexes.contains(1) ? .italic : nil,
                sender.selectedSegmentIndexes.contains(2) ? .underline : nil
            ].compactMap { $0 })

            delegate?.textToolbarFontStyleChanged(self)
        case selectTextAlignmentControl:
            textAlignment = NSTextAlignment(rawValue: Int(sender.selectedSegmentIndex)) ?? .natural
            delegate?.textToolbarTextAlignmentChanged(self)
        default:
            assertionFailure("Not implemented")
        }
    }
}

private extension TextToolbar {
    func setup() {
        shouldAutoAdjustAxis = false
        axis = .vertical
        innerInset = 0
        distribution = .equalCentering

        var commandItemsInGroups: [[UIView]] = []

        for commands in commandsInGroups {
            let commandItems: [UIView] = (commands.enumerated().compactMap { offset, command in
                switch command {
                case is Commands.SelectFontFamily:
                    let segmentedControl = UberSegmentedControl(items: [fontFamily ?? "N/A"])

                    segmentedControl.setImage(UIImage.fromBundle("icon-drop-down-arrow"), forSegmentAt: 0)
                    segmentedControl.setSegmentSemanticContentAttribute(at: 0, attribute: .forceRightToLeft)
                    segmentedControl.setSegmentImageEdgeInsets(at: 0, insets: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 0))

                    segmentedControl.isMomentary = true
                    segmentedControl.addTarget(self, action: #selector(controlSelected), for: .valueChanged)

                    selectFontFamilyControl = segmentedControl

                    return segmentedControl
                case is Commands.SelectFontColor:
                    let control = RingButton()

                    control.addTarget(self, action: #selector(controlSelected), for: .touchUpInside)

                    selectFontColorControl = control

                    return control
                case is Commands.SelectFontStyle:
                    let segmentedControl = UberSegmentedControl(items: [
                        UIImage.fromBundle("icon-font-style-bold"),
                        UIImage.fromBundle("icon-font-style-italic"),
                        UIImage.fromBundle("icon-font-style-underline")
                    ], allowsMultipleSelection: true)

                    segmentedControl.addTarget(self, action: #selector(controlSelected), for: .valueChanged)

                    selectFontStyleControl = segmentedControl

                    return segmentedControl
                case is Commands.SelectTextAlignment:
                    let segmentedControl = UberSegmentedControl(items: [
                        UIImage.fromBundle("icon-text-align-left"),
                        UIImage.fromBundle("icon-text-align-center"),
                        UIImage.fromBundle("icon-text-align-right"),
                        UIImage.fromBundle("icon-text-align-justify")
                    ])

                    segmentedControl.addTarget(self, action: #selector(controlSelected), for: .valueChanged)

                    selectTextAlignmentControl = segmentedControl

                    return segmentedControl
                default:
                    return nil
                }
            })

            commandItemsInGroups.append(commandItems)
        }

        var innerToolbars: [ArrangeableToolbar] = []

        for commandItems in commandItemsInGroups {
            let innerToolbar = ArrangeableToolbar(items: commandItems)

            innerToolbar.axis = .horizontal
            innerToolbar.spacing = style.itemSpacing
            innerToolbar.shouldAutoAdjustAxis = false
            innerToolbar.distribution = .fill

            innerToolbars.append(innerToolbar)
        }

        let stackView = ArrangeableToolbar(items: innerToolbars)

        stackView.axis = .vertical
        stackView.spacing = style.itemSpacing
        stackView.distribution = .equalCentering
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
