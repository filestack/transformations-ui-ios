//
//  ObjectPanHandlerDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 2/27/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

protocol ObjectPanHandlerDelegate: class {
    /// Called when a movement is detected.
    ///
    /// - Parameters:
    ///   - position: A `CGPoint` containing the latest position.
    ///   - delta: A `CGPoint` containing the delta since the last movement.
    ///   - finished: Whether the movement has finished.
    func objectPanHandlerMoved(handler: ObjectPanHandler, position: CGPoint, delta: CGPoint, finished: Bool)
}

class ObjectPanHandler {
    weak var delegate: ObjectPanHandlerDelegate?

    weak var object: ObjectRenderNode? {
        didSet { previousPoint = nil }
    }

    private var previousPoint: CGPoint? = nil
    private var finished: Bool = true

    init(delegate: ObjectPanHandlerDelegate? = nil) {
        self.delegate = delegate
    }

    func handle(recognizer: UIPanGestureRecognizer) {
        guard let groupView = (object?.group as? ViewableNode)?.view else { return }

        let point = recognizer.location(in: groupView)

        switch recognizer.state {
        case .began:
            fallthrough
        case .changed:
            finished = false
        case .ended:
            fallthrough
        default:
            finished = true
        }

        if let previousPoint = previousPoint {
            let delta = point.substracting(point: previousPoint)

            delegate?.objectPanHandlerMoved(handler: self, position: point, delta: delta, finished: finished)
        }

        previousPoint = finished ? nil : point
    }
}
