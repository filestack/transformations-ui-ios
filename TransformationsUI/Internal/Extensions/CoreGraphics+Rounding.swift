//
//  CoreGraphics+Rounding.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 15/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    func rounded(rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGPoint {
        return CGPoint(x: x.rounded(rule), y: y.rounded(rule))
    }
}

extension CGSize {
    func rounded(rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGSize {
        return CGSize(width: width.rounded(rule), height: height.rounded(rule))
    }
}
