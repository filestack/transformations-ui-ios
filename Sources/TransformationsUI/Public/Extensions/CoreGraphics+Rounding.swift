//
//  CoreGraphics+Rounding.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 15/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import CoreGraphics

public extension CGPoint {
    func rounded(rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGPoint {
        return CGPoint(x: x.rounded(rule), y: y.rounded(rule))
    }
}

public extension CGSize {
    func rounded(rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGSize {
        return CGSize(width: width.rounded(rule), height: height.rounded(rule))
    }
}

public extension CGRect {
    func rounded(rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGRect {
        return rounded(originRule: rule, sizeRule: rule)
    }

    func rounded(originRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero,
                 sizeRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGRect {
        return CGRect(origin: origin.rounded(rule: originRule), size: size.rounded(rule: sizeRule))
    }
}
