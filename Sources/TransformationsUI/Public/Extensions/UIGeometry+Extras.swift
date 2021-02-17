//
//  UIGeometry+Extras.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 15/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit.UIGeometry

public extension UIEdgeInsets {
    /// Returns a new `UIEdgeInsets` with rounded insets.
    ///
    /// - Parameter rule: A `FloatingPointRoundingRule` used for rounding insets.
    func rounded(rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> UIEdgeInsets {
        return UIEdgeInsets(top: top.rounded(rule),
                            left: left.rounded(rule),
                            bottom: bottom.rounded(rule),
                            right: right.rounded(rule))
    }

    /// Returns a new `UIEdgeInsets` with clipped inset values.
    func clipped() -> UIEdgeInsets {
        return UIEdgeInsets(top: max(0, top),
                            left: max(0, left),
                            bottom: max(0, bottom),
                            right: max(0, right))
    }

    /// Returns the result of adding two `UIEdgeInsets`.
    ///
    /// - Parameter insets: The `UIEdgeInsets` that is being added to `self`.
    func adding(insets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: top + insets.top,
                            left: left + insets.left,
                            bottom: bottom + insets.bottom,
                            right: right + insets.right)
    }
}
