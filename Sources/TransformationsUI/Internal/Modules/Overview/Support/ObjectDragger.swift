//
//  ObjectDragger.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

class ObjectDragger {
    // MARK: - Internal Properties

    weak var object: ObjectRenderNode? = nil {
        didSet {
            if object !== oldValue {
                lastRadians = nil
                originalTransform = nil
            }
        }
    }

    var handle: HandleType? = .none

    // MARK: - Private Properties

    private var lastRadians: CGFloat? = nil
    private var originalTransform: CGAffineTransform? = nil
}

// MARK: - Internal Functions

extension ObjectDragger {
    func drag(position: CGPoint, delta: CGPoint, finished: Bool) {
        guard let object = object, let handle = handle else { return }

        let tDelta = delta.applying(object.transform.inverted())
        var cDelta = CGPoint.zero

        switch handle {
        case .center:
            cDelta = delta
        case .topLeft:
            cDelta = CGPoint(x: tDelta.x / 2, y: tDelta.y / 2).applying(object.transform)
            object.bounds.size = object.bounds.size.adding(width: -tDelta.x, height: -tDelta.y)
        case .topRight:
            cDelta = CGPoint(x: tDelta.x / 2, y: tDelta.y / 2).applying(object.transform)
            object.bounds.size = object.bounds.size.adding(width: tDelta.x, height: -tDelta.y)
        case .bottomLeft:
            cDelta = CGPoint(x: tDelta.x / 2, y: tDelta.y / 2).applying(object.transform)
            object.bounds.size = object.bounds.size.adding(width: -tDelta.x, height: tDelta.y)
        case .bottomRight:
            cDelta = CGPoint(x: tDelta.x / 2, y: tDelta.y / 2).applying(object.transform)
            object.bounds.size = object.bounds.size.adding(width: tDelta.x, height: tDelta.y)
        case .top:
            cDelta = CGPoint(x: 0, y: tDelta.y / 2).applying(object.transform)
            object.bounds.size.height -= tDelta.y
        case .right:
            cDelta = CGPoint(x: tDelta.x / 2, y: 0).applying(object.transform)
            object.bounds.size.width += tDelta.x
        case .bottom:
            cDelta = CGPoint(x: 0, y: tDelta.y / 2).applying(object.transform)
            object.bounds.size.height += tDelta.y
        case .left:
            cDelta = CGPoint(x: tDelta.x / 2, y: 0).applying(object.transform)
            object.bounds.size.width -= tDelta.x
        case .rotate:
            if originalTransform == nil {
                // Keep a reference to the layer transform before applying any rotations.
                originalTransform = object.transform
            }

            guard let originalTransform = originalTransform else { break }

            // Calculate rotation angle offset.
            let deltaX = object.center.x - position.x
            let deltaY = object.center.y - position.y
            let delta = CGPoint(x: deltaX, y: deltaY).applying(originalTransform)
            let radians = atan2(delta.y, delta.x) - (CGFloat.pi / 2)

            if let lastRadians = lastRadians {
                object.transform = object.transform.rotated(by: radians - lastRadians)
            }

            lastRadians = radians
        case .scale:
            // Keep aspect ratio
            let ratio = object.bounds.size.width / object.bounds.size.height

            let oldSize: CGSize = object.bounds.size
            let newSize: CGSize

            if abs(tDelta.x) > abs(tDelta.y) {
                newSize = CGSize(width: oldSize.width + tDelta.x,
                                 height: (oldSize.width + tDelta.x) * (1 / ratio))
            } else {
                newSize = CGSize(width: (oldSize.height + tDelta.y) * ratio,
                                 height: oldSize.height + tDelta.y)
            }

            let aspectCorrectedDelta = CGPoint(x: newSize.width - oldSize.width,
                                               y: newSize.height - oldSize.height)

            cDelta = CGPoint(x: aspectCorrectedDelta.x / 2, y: aspectCorrectedDelta.y / 2).applying(object.transform)

            object.bounds.size = newSize
        }

        object.center = object.center.adding(point: cDelta)

        if finished {
            object.bounds.ensurePositiveSize()
            lastRadians = nil
            originalTransform = nil
        }
    }
}
