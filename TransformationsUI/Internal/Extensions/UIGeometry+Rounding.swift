//
//  UIGeometry+Rounding.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 15/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit.UIGeometry

extension UIEdgeInsets {
    func rounded(rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> UIEdgeInsets {
        return UIEdgeInsets(top: top.rounded(rule),
                            left: left.rounded(rule),
                            bottom: bottom.rounded(rule),
                            right: right.rounded(rule))
    }
}
