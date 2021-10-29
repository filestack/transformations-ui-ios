//
//  EditorToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 08/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

open class EditorToolbar: ArrangeableToolbar {
    // MARK: - Public Properties

    public let style: EditorToolbarStyle

    // MARK: - Overridable Properties

    open override var intrinsicContentSize: CGSize {
        if let height = style.fixedHeight {
            return CGSize(width: UIView.noIntrinsicMetric, height: height)
        } else {
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
    }

    // MARK: - Overridable Functions

    open override func setItems(_ items: [UIView] = [], animated: Bool = false) {
        super.setItems(items, animated: animated)
        setNeedsLayout()
    }

    // MARK: - Lifecycle

    public init(style: EditorToolbarStyle = .accented) {
        self.style = style
        super.init()

        setup()
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Functions

private extension EditorToolbar {
    func setup() {
        backgroundColor = style.backgroundColor
        innerInsets = style.innerInsets
        spacing = style.itemSpacing
        axis = style.axis
        distribution = .equalCentering
    }
}
