//
//  EditorToolbarStyle.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 24/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import TUIKit

public struct EditorToolbarStyle {
    /// Defines the toolbar background color, or `nil` if transparency is required.
    public var backgroundColor: UIColor? = nil
    /// Defines the toolbar's inner insets.
    public var innerInsets: UIEdgeInsets = .zero
    /// Defines the space between items in the toolbar.
    public var itemSpacing: CGFloat = .zero
    /// Defines the toolbar's fixed height.
    public var fixedHeight: CGFloat? = nil
    /// Defines the toolbar items style.
    public var itemStyle = EditorToolbarItemStyle.accented
    /// Defines the toolbar's layout axis. Defaults to `horizontal`.
    public var axis = NSLayoutConstraint.Axis.horizontal
    /// Defines whether the toolbar item is highlightable.
    public var buttonConfig = TUIButton.UIConfig()

    public init(_ build: (inout EditorToolbarStyle) -> Void) {
        build(&self)
    }
}
