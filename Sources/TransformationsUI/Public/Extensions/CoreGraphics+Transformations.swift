//
//  CoreGraphics+Transformations.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 05/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import CoreGraphics

public extension CGRect {
    func scaled(by scale: CGFloat) -> CGRect {
        return applying(CGAffineTransform(scaleX: scale, y: scale))
    }

    func translated(using point: CGPoint) -> CGRect {
        return CGRect(origin: origin.adding(point: point), size: size)
    }

    mutating func ensurePositiveSize() {
        if size.width < 0 {
            origin.x += size.width
        }

        if size.height < 0 {
            origin.y += size.height
        }

        size = CGSize(width: abs(width), height: abs(height))
    }
}

public extension CGPoint {
    func movedBy(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        return adding(point: CGPoint(x: x, y: y))
    }

    func scaledBy(x: CGFloat, y: CGFloat) -> CGPoint {
        return applying(CGAffineTransform(scaleX: x, y: y))
    }

    func adding(point: CGPoint) -> CGPoint {
        return applying(CGAffineTransform(translationX: point.x, y: point.y))
    }

    func substracting(point: CGPoint) -> CGPoint {
        return applying(CGAffineTransform(translationX: -point.x, y: -point.y))
    }
}

public extension CGSize {
    func adding(width: CGFloat = 0, height: CGFloat = 0) -> CGSize {
        return CGSize(width: self.width + width, height: self.height + height)
    }

    func scaledBy(x: CGFloat, y: CGFloat) -> CGSize {
        return applying(CGAffineTransform(scaleX: x, y: y))
    }
}
