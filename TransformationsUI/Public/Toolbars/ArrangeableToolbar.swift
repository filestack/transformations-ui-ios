//
//  ArrangeableToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 07/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

open class ArrangeableToolbar: UIView {
    // MARK: - Open Properties

    open var shouldAutoAdjustAxis: Bool = true

    open var distribution: UIStackView.Distribution {
        get { stackView.distribution }
        set { stackView.distribution = newValue }
    }

    open var alignment: UIStackView.Alignment {
        get { stackView.alignment }
        set { stackView.alignment = newValue }
    }

    open var axis: NSLayoutConstraint.Axis {
        get { stackView.axis }
        set { stackView.axis = newValue }
    }

    open var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }

    open var items: [UIView] {
        return stackView.arrangedSubviews
    }

    open var innerInset: CGFloat = 0 {
        didSet { setupViews() }
    }

    open func setCustomSpacing(_ spacing: CGFloat, after arrangedSubview: UIView) {
        stackView.setCustomSpacing(spacing, after: arrangedSubview)
    }

    // MARK: - Private Properties

    private lazy var stackView = UIStackView()
    private var shouldSetupViews = true
    private var stackViewConstraints = [NSLayoutConstraint]()

    // MARK: - Lifecycle
    
    public init() {
        super.init(frame: .infinite)
    }

    public init(items: [UIView]) {
        super.init(frame: .infinite)

        for item in items {
            stackView.addArrangedSubview(item)
        }
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Functions
    
    public func addItem(_ item: UIView) {
        stackView.addArrangedSubview(item)
    }

    public func insertItem(_ item: UIView, at stackIndex: Int) {
        stackView.insertArrangedSubview(item, at: stackIndex)
    }

    public func removeItem(_ item: UIView) {
        item.removeFromSuperview()
        stackView.removeArrangedSubview(item)
    }

    public func removeAllItems() {
        for item in stackView.arrangedSubviews {
            removeItem(item)
        }
    }
}

extension ArrangeableToolbar {
    open override func layoutSubviews() {
        super.layoutSubviews()

        if shouldSetupViews {
            shouldSetupViews = false
            setupViews()
        }

        if shouldAutoAdjustAxis {
            rearrangeViews()
        }
    }
}

private extension ArrangeableToolbar {
    func setupViews() {
        removeConstraints(stackViewConstraints)
        stackViewConstraints = fill(with: stackView, inset: innerInset, activate: true)
    }

    func rearrangeViews() {
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        // In vR we distribute the stack along the horizontal axis.
        case (_, .regular):
            stackView.axis = .horizontal
        // In vC we distribute the stack along the vertical axis, and, optionally,
        // we arrange the items from bottom to top.
        case (_, .compact):
            stackView.axis = .vertical
        case (_, _):
            break
        }
    }
}
