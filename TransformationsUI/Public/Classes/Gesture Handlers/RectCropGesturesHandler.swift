//
//  RectCropGesturesHandler.swift
//  TransformationsUI
//
//  Created by Mihály Papp on 12/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

protocol RectCropGesturesHandlerDelegate: EditDataSource {
    func updateCropInset(_ inset: UIEdgeInsets)
}

class RectCropGesturesHandler {
    typealias RelativeInsets = (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)

    enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight, center, top, bottom, left, right
        static var all: [Corner] = [.topLeft, .topRight, .bottomLeft, .bottomRight, .center, .top, .bottom, .left, .right]
    }

    weak var delegate: RectCropGesturesHandlerDelegate?

    private var beginInset: RelativeInsets?
    private var movingCorner: Corner?
    private var relativeCropInsets = RectCropGesturesHandler.initialInsets

    init(delegate: RectCropGesturesHandlerDelegate) {
        self.delegate = delegate
    }

    var croppedRect: CGRect {
        return delegate?.virtualFrame.inset(by: cropInsets) ?? .zero
    }

    var actualEdgeInsets: UIEdgeInsets {
        guard let delegate = delegate else { return .zero }

        let actualImageRect = delegate.convertRectFromVirtualFrameToImageFrame(croppedRect)

        return UIEdgeInsets(top: actualImageRect.minY - delegate.imageFrame.minY,
                            left: actualImageRect.minX - delegate.imageFrame.minX,
                            bottom: delegate.imageFrame.maxY - actualImageRect.maxY,
                            right: delegate.imageFrame.maxX - actualImageRect.maxX)
    }

    func reset() {
        relativeCropInsets = RectCropGesturesHandler.initialInsets
    }

    private static var initialInsets: RelativeInsets = RelativeInsets(top: 0, left: 0, bottom: 0, right: 0)
}

extension RectCropGesturesHandler {
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: recognizer.view)
        let origin = recognizer.location(in: recognizer.view).movedBy(x: -translation.x, y: -translation.y)

        handle(translation: translation, from: origin, forState: recognizer.state)
    }

    func rotateCounterClockwise() {
        let rotatedInsets = RelativeInsets(top: relativeCropInsets.right,
                                           left: relativeCropInsets.top,
                                           bottom: relativeCropInsets.left,
                                           right: relativeCropInsets.bottom)

        relativeCropInsets = rotatedInsets
    }
}

private extension RectCropGesturesHandler {
    var cropInsets: UIEdgeInsets {
        get {
            return edgeInsets(from: relativeCropInsets)
        }

        set {
            relativeCropInsets = relativeInsets(from: newValue)
            delegate?.updateCropInset(newValue)
        }
    }

    func edgeInsets(from relativeInsets: RelativeInsets?) -> UIEdgeInsets {
        guard let delegate = delegate, let relativeInsets = relativeInsets else { return .zero }

        return UIEdgeInsets(top: relativeInsets.top * delegate.virtualFrame.height,
                            left: relativeInsets.left * delegate.virtualFrame.width,
                            bottom: relativeInsets.bottom * delegate.virtualFrame.height,
                            right: relativeInsets.right * delegate.virtualFrame.width)
    }

    func relativeInsets(from edgeInsets: UIEdgeInsets?) -> RelativeInsets {
        guard let delegate = delegate, let edgeInsets = edgeInsets else {
            return RelativeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

        return RelativeInsets(top: edgeInsets.top / delegate.virtualFrame.height,
                              left: edgeInsets.left / delegate.virtualFrame.width,
                              bottom: edgeInsets.bottom / delegate.virtualFrame.height,
                              right: edgeInsets.right / delegate.virtualFrame.width)
    }
}

private extension RectCropGesturesHandler {
    func handle(translation: CGPoint, from origin: CGPoint, forState state: UIGestureRecognizer.State) {
        guard let delegate = delegate else { return }

        switch state {
        case .began:
            beginInset = relativeCropInsets
            let adjustedPoint = origin.movedBy(x: -delegate.virtualFrame.origin.x, y: -delegate.virtualFrame.origin.y)
            movingCorner = nearestCorner(for: adjustedPoint)
            move(by: translation)
        case .changed:
            move(by: translation)
        case .ended:
            move(by: translation)
            beginInset = nil
        case .cancelled,
             .failed:
            resetTranslation(to: edgeInsets(from: beginInset))
        case .possible:
            fallthrough
        @unknown default:
            return
        }
    }

    func location(of corner: Corner) -> CGPoint {
        guard let delegate = delegate else { return .zero }

        let insets = cropInsets

        let top: CGFloat = insets.top
        let bottom: CGFloat = delegate.virtualFrame.height - insets.bottom
        let left: CGFloat = insets.left
        let right: CGFloat = delegate.virtualFrame.width - insets.right

        switch corner {
        case .topLeft:
            return CGPoint(x: left, y: top)
        case .topRight:
            return CGPoint(x: right, y: top)
        case .bottomLeft:
            return CGPoint(x: left, y: bottom)
        case .bottomRight:
            return CGPoint(x: right, y: bottom)
        case .top:
            return CGPoint(x: (left + right) / 2, y: top)
        case .bottom:
            return CGPoint(x: (left + right) / 2, y: bottom)
        case .left:
            return CGPoint(x: left, y: (top + bottom) / 2)
        case .right:
            return CGPoint(x: right, y: (top + bottom) / 2)
        case .center:
            return CGPoint(x: (left + right) / 2, y: (top + bottom) / 2)
        }
    }

    func nearestCorner(for point: CGPoint) -> Corner? {
        typealias CornerDistance = (corner: Corner, distance: CGFloat)

        var distances = Corner.all.map { CornerDistance(corner: $0, distance: location(of: $0).distance(to: point)) }

        distances = distances.filter { (_, distance) -> Bool in distance < 100 }
        distances.sort(by: { $0.distance < $1.distance })

        return distances.first?.corner
    }

    func resetTranslation(to insets: UIEdgeInsets?) {
        guard let insets = insets else { return }

        cropInsets = insets
    }

    func move(by translation: CGPoint) {
        guard let delegate = delegate, let beginInset = beginInset, let movingCorner = movingCorner else { return }

        let startInset = edgeInsets(from: beginInset)
        var top = startInset.top
        var left = startInset.left
        var right = startInset.right
        var bottom = startInset.bottom
        let minHeight = delegate.virtualFrame.height - top - bottom
        let minWidth = delegate.virtualFrame.width - left - right

        switch movingCorner {
        case .topLeft:
            top += min(translation.y, minHeight)
            left += min(translation.x, minWidth)
        case .topRight:
            top += min(translation.y, minHeight)
            right += min(-translation.x, minWidth)
        case .bottomLeft:
            bottom += min(-translation.y, minHeight)
            left += min(translation.x, minWidth)
        case .bottomRight:
            bottom += min(-translation.y, minHeight)
            right += min(-translation.x, minWidth)
        case .top:
            top += min(translation.y, minHeight)
        case .bottom:
            bottom += min(-translation.y, minHeight)
        case .left:
            left += min(translation.x, minWidth)
        case .right:
            right += min(-translation.x, minWidth)
        case .center:
            let moveVertical = clamp(translation.y, min: -top, max: bottom)
            let moveHorizontal = clamp(translation.x, min: -left, max: right)
            top += moveVertical
            left += moveHorizontal
            right += -moveHorizontal
            bottom += -moveVertical
        }

        cropInsets = UIEdgeInsets(top: max(0, top), left: max(0, left), bottom: max(0, bottom), right: max(0, right))
    }
}
