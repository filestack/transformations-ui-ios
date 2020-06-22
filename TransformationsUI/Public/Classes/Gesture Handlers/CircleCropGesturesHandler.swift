//
//  CircleCropGesturesHandler.swift
//  TransformationsUI
//
//  Created by Mihály Papp on 12/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

public protocol CircleCropGesturesHandlerDelegate: EditDataSource {
    func updateCircle(_ center: CGPoint, radius: CGFloat)
}

public class CircleCropGesturesHandler {
    // MARK: - Public Properties

    public weak var delegate: CircleCropGesturesHandlerDelegate?

    // MARK: - Private Properties

    private lazy var relativeCircle = initialCircle()
    private var beginCircle: RelativeCircle?
    private var boundaryThreshold: CGFloat = 20
    private var action: Action = .none

    // MARK: - Lifecycle

    public init(delegate: CircleCropGesturesHandlerDelegate) {
        self.delegate = delegate
    }
}

// MARK: - Public Functions and Computed Properties

public extension CircleCropGesturesHandler {
    var circleCenter: CGPoint {
        get { point(fromRelativeX: relativeCircle.centerX, relativeY: relativeCircle.centerY) }

        set {
            relativeCircle.centerX = relativeX(from: newValue) ?? 0
            relativeCircle.centerY = relativeY(from: newValue) ?? 0
            sendUpdate()
        }
    }

    var circleRadius: CGFloat {
        get { length(fromRelativeLenght: relativeCircle.radius) }

        set {
            relativeCircle.radius = relativeLength(fromLenght: newValue)
            sendUpdate()
        }
    }

    var actualCenter: CGPoint {
        guard let delegate = delegate else { return .zero }

        let actualPoint = point(fromRelativeX: relativeCircle.centerX, relativeY: relativeCircle.centerY)

        return delegate.convertPointFromVirtualFrameToImageFrame(actualPoint)
    }

    var actualRadius: CGFloat {
        guard let delegate = delegate else { return .zero }

        return shorterEdge * relativeCircle.radius * (1 / delegate.zoomScale)
    }

    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: recognizer.view)
        let origin = recognizer.location(in: recognizer.view).movedBy(x: -translation.x, y: -translation.y)
        let circleCenter = self.circleCenter

        let distanceFromCenter = sqrt(
            pow(abs(origin.x + translation.x - circleCenter.x), 2) +
            pow(abs(origin.y + translation.y - circleCenter.y), 2)
        )

        let scaling: CGFloat = distanceFromCenter / circleRadius

        if recognizer.state == .began {
            // Determine what action has just began.
            if distanceFromCenter <= circleRadius {
                // Gesture initiated inside the circle.
                let distanceFromBoundary = circleRadius - distanceFromCenter
                // Close to the boundary? scale, else move.
                action = distanceFromBoundary < boundaryThreshold ? .scale : .move
            } else {
                action = .none
            }
        }

        switch action {
        case .move:
            handle(translation: translation, from: origin, forState: recognizer.state)
        case .scale:
            handle(scaling: scaling, center: origin, forState: recognizer.state)
        case .none:
            return
        }
    }

    func reset() {
        relativeCircle = initialCircle()
    }
}

// MARK: - Private Functions and Computed Properties

private extension CircleCropGesturesHandler {
    typealias RelativeCircle = (centerX: CGFloat, centerY: CGFloat, radius: CGFloat)

    var maxRadius: CGFloat { return 0.5 }
    var minRadius: CGFloat { return 0.1 }

    var shorterEdge: CGFloat {
        guard let delegate = delegate else { return 0 }

        return min(delegate.virtualFrame.width, delegate.virtualFrame.height)
    }

    func initialCircle() -> RelativeCircle {
        return RelativeCircle(centerX: 0.5, centerY: 0.5, radius: 0.4)
    }

    func point(fromRelativeX relativeX: CGFloat, relativeY: CGFloat) -> CGPoint {
        guard let delegate = delegate else { return .zero }

        return CGPoint(x: delegate.virtualFrame.origin.x + delegate.virtualFrame.width * relativeX,
                       y: delegate.virtualFrame.origin.y + delegate.virtualFrame.height * relativeY)
    }

    func relativeX(from point: CGPoint) -> CGFloat? {
        guard let delegate = delegate else { return nil }

        return (point.x - delegate.virtualFrame.origin.x) / delegate.virtualFrame.width
    }

    func relativeY(from point: CGPoint) -> CGFloat? {
        guard let delegate = delegate else { return nil }

        return (point.y - delegate.virtualFrame.origin.y) / delegate.virtualFrame.height
    }

    func length(fromRelativeLenght relativeLenght: CGFloat) -> CGFloat {
        return shorterEdge * relativeLenght
    }

    func relativeLength(fromLenght length: CGFloat) -> CGFloat {
        return length / shorterEdge
    }

    func sendUpdate() {
        delegate?.updateCircle(actualCenter, radius: actualRadius)
    }
}

// MARK: - Translation and Scaling Handling Functions

private extension CircleCropGesturesHandler {
    enum Action {
        case none
        case move
        case scale
    }

    // Handle move gesture
    func handle(translation: CGPoint, from origin: CGPoint, forState state: UIGestureRecognizer.State) {
        switch state {
        case .began:
            beginCircle = relativeCircle
            move(by: translation)
        case .changed:
            move(by: translation)
        case .ended:
            move(by: translation)
            beginCircle = nil
        case .cancelled,
             .failed:
            reset(to: beginCircle)
            fallthrough
        case .possible:
            fallthrough
        @unknown default:
            action = .none
        }
    }

    // Handle scaling gesture
    func handle(scaling: CGFloat, center _: CGPoint, forState state: UIGestureRecognizer.State) {
        switch state {
        case .began:
            beginCircle = relativeCircle
            scale(by: scaling)
        case .changed:
            scale(by: scaling)
        case .ended:
            scale(by: scaling)
            beginCircle = nil
        case .cancelled,
             .failed:
            reset(to: beginCircle)
            fallthrough
        case .possible:
            fallthrough
        @unknown default:
            action = .none
        }
    }

    func move(by translation: CGPoint) {
        guard let beginCircle = beginCircle else { return }
        guard let delegate = delegate else { return }

        let startCenter = point(fromRelativeX: beginCircle.centerX, relativeY: beginCircle.centerY)
        let topSpace = delegate.virtualFrame.minY - startCenter.y + circleRadius
        let bottomSpace = delegate.virtualFrame.maxY - startCenter.y - circleRadius
        let leftSpace = delegate.virtualFrame.minX - startCenter.x + circleRadius
        let rightSpace = delegate.virtualFrame.maxX - startCenter.x - circleRadius
        let moveY = clamp(translation.y, min: topSpace, max: bottomSpace)
        let moveX = clamp(translation.x, min: leftSpace, max: rightSpace)

        circleCenter = startCenter.movedBy(x: moveX, y: moveY)
    }

    func scale(by scale: CGFloat) {
        let adjustedScale = scale / 2 + 0.5
        let radius = clamp(relativeCircle.radius * adjustedScale, min: minRadius, max: maxRadius)

        circleRadius = length(fromRelativeLenght: radius)
        move(by: .zero)
    }

    func reset(to circle: RelativeCircle?) {
        guard let circle = circle else { return }

        circleCenter = point(fromRelativeX: circle.centerX, relativeY: circle.centerY)
        circleRadius = length(fromRelativeLenght: circle.radius)
    }
}
