//
//  UIView+Constraints.swift
//  TransformationsUI
//
//  Created by Mihály Papp on 05/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

extension UIView {
    @discardableResult func fill(with subview: UIView,
                                 connectingEdges: [NSLayoutConstraint.Attribute] = [.top, .bottom, .left, .right],
                                 inset: CGFloat = 0,
                                 withSafeAreaRespecting useSafeArea: Bool = false,
                                 activate: Bool = false) -> [NSLayoutConstraint] {
        subview.translatesAutoresizingMaskIntoConstraints = false

        if !subviews.contains(subview) {
            addSubview(subview)
        }

        return connect(edges: connectingEdges, of: subview, inset: inset, withSafeAreaRespecting: useSafeArea, activate: activate)
    }

    @discardableResult func connect(edges: [NSLayoutConstraint.Attribute],
                                    of subview: UIView,
                                    inset: CGFloat = 0,
                                    withSafeAreaRespecting useSafeArea: Bool = false,
                                    activate: Bool = false) -> [NSLayoutConstraint] {
        guard subviews.contains(subview) else { return [] }

        let primaryItem = useSafeArea ? safeAreaLayoutGuide : self
        var constraints = [NSLayoutConstraint]()

        for edge in edges {
            let reversedEdges: [NSLayoutConstraint.Attribute] = [.top, .left, .topMargin, .leftMargin]
            let offset = reversedEdges.contains(edge) ? -inset : inset

            let constraint = NSLayoutConstraint(item: primaryItem, attribute: edge, relatedBy: .equal,
                               toItem: subview, attribute: edge, multiplier: 1, constant: offset)

            constraint.isActive = activate
            constraints.append(constraint)
        }

        return constraints
    }
}
