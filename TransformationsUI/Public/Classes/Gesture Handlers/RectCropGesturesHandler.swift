//
//  RectCropGesturesHandler.swift
//  TransformationsUI
//
//  Created by Mihály Papp on 12/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit
import AVFoundation

public protocol RectCropGesturesHandlerDelegate: EditDataSource {
    func updateCropInset(_ inset: UIEdgeInsets)
}

private extension UIEdgeInsets {
    func adding(edgeInset: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: top + edgeInset.top,
                            left: left + edgeInset.left,
                            bottom: bottom + edgeInset.bottom,
                            right: right + edgeInset.right)
    }
}

public class RectCropGesturesHandler {
    // MARK: - Public Properties

    public weak var delegate: RectCropGesturesHandlerDelegate?

    public var croppedRect: CGRect {
        return delegate?.virtualFrame.inset(by: cropInsets) ?? .zero
    }

    public var actualEdgeInsets: UIEdgeInsets {
        guard let delegate = delegate else { return .zero }

        let actualImageRect = delegate.convertRectFromVirtualFrameToImageFrame(croppedRect)

        return UIEdgeInsets(top: actualImageRect.minY - delegate.imageFrame.minY,
                            left: actualImageRect.minX - delegate.imageFrame.minX,
                            bottom: delegate.imageFrame.maxY - actualImageRect.maxY,
                            right: delegate.imageFrame.maxX - actualImageRect.maxX)
    }

    public var keepAspectRatio: Bool = false {
        didSet { reset() }
    }

    public var aspectRatio: CGSize {
        didSet { reset() }
    }

    // MARK: - Private Properties

    private var beginInset: UIEdgeInsets?
    private var movingCorner: Corner?
    private lazy var relativeCropInsets = UIEdgeInsets.zero

    // MARK: - Lifecycle

    public init(delegate: RectCropGesturesHandlerDelegate) {
        self.delegate = delegate
        self.aspectRatio = delegate.imageSize
        reset()
    }
}

// MARK: - Public Functions

public extension RectCropGesturesHandler {
    func reset() {
        if keepAspectRatio {
            let frame = delegate?.virtualFrame ?? .zero
            let aspectAdjustedFrame = AVMakeRect(aspectRatio: aspectRatio, insideRect: frame)

            let insets = UIEdgeInsets(top: abs(frame.minY - aspectAdjustedFrame.minY),
                                      left: abs(frame.minX - aspectAdjustedFrame.minX),
                                      bottom: abs(frame.maxY - aspectAdjustedFrame.maxY),
                                      right: abs(frame.maxX - aspectAdjustedFrame.maxX))

            relativeCropInsets = keepAspectRatio ? relativeInsets(from: insets) : .zero
        } else {
            relativeCropInsets = .zero
        }
    }

    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: recognizer.view)
        let origin = recognizer.location(in: recognizer.view).movedBy(x: -translation.x, y: -translation.y)

        handle(translation: translation, from: origin, forState: recognizer.state)
    }
}

// MARK: - Private Functions and Computed Properties

private extension RectCropGesturesHandler {
    typealias RelativeInsets = (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)

    enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight, center, top, bottom, left, right
        static var all: [Corner] = [.topLeft, .topRight, .bottomLeft, .bottomRight, .center, .top, .bottom, .left, .right]
    }

    var cropInsets: UIEdgeInsets {
        get {
            return edgeInsets(from: relativeCropInsets)
        }

        set {
            relativeCropInsets = relativeInsets(from: newValue)
            delegate?.updateCropInset(newValue)
        }
    }

    func edgeInsets(from relativeInsets: UIEdgeInsets?) -> UIEdgeInsets {
        guard let delegate = delegate, let relativeInsets = relativeInsets else { return .zero }

        return UIEdgeInsets(top: relativeInsets.top * delegate.virtualFrame.height,
                            left: relativeInsets.left * delegate.virtualFrame.width,
                            bottom: relativeInsets.bottom * delegate.virtualFrame.height,
                            right: relativeInsets.right * delegate.virtualFrame.width)
    }

    func relativeInsets(from edgeInsets: UIEdgeInsets?) -> UIEdgeInsets {
        guard let delegate = delegate, let edgeInsets = edgeInsets else { return .zero }

        return UIEdgeInsets(top: edgeInsets.top / delegate.virtualFrame.height,
                            left: edgeInsets.left / delegate.virtualFrame.width,
                            bottom: edgeInsets.bottom / delegate.virtualFrame.height,
                            right: edgeInsets.right / delegate.virtualFrame.width)
    }
}

// MARK: - Translation and Scaling Handling Functions

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
            reset(to: edgeInsets(from: beginInset))
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

    func move(by translation: CGPoint) {
        guard let delegate = delegate, let beginInset = beginInset, let movingCorner = movingCorner else { return }

        let startInset = edgeInsets(from: beginInset)
        var insetOffset = UIEdgeInsets.zero
        let top = startInset.top
        let left = startInset.left
        let right = startInset.right
        let bottom = startInset.bottom
        let minHeight = delegate.virtualFrame.height - top - bottom
        let minWidth = delegate.virtualFrame.width - left - right
        let ratio = delegate.imageFrame.height / delegate.imageFrame.width

        switch movingCorner {
        // Corner regions
        case .topLeft:
            insetOffset.top = min(translation.y, minHeight)
            insetOffset.left = min(translation.x, minWidth)

            if keepAspectRatio {
                let offset = max(max(-startInset.top, insetOffset.top), max(-startInset.left, insetOffset.left))
                insetOffset.top = offset * ratio
                insetOffset.left = offset
            }
        case .topRight:
            insetOffset.top = min(translation.y, minHeight)
            insetOffset.right = min(-translation.x, minWidth)

            if keepAspectRatio {
                let offset = max(max(-startInset.top, insetOffset.top), max(-startInset.right, insetOffset.right))
                insetOffset.top = offset * ratio
                insetOffset.right = offset
            }
        case .bottomLeft:
            insetOffset.bottom = min(-translation.y, minHeight)
            insetOffset.left = min(translation.x, minWidth)

            if keepAspectRatio {
                let offset = max(max(-startInset.bottom, insetOffset.bottom), max(-startInset.left, insetOffset.left))
                insetOffset.bottom = offset * ratio
                insetOffset.left = offset
            }
        case .bottomRight:
            insetOffset.bottom = min(-translation.y, minHeight)
            insetOffset.right = min(-translation.x, minWidth)

            if keepAspectRatio {
                let offset = max(max(-startInset.bottom, insetOffset.bottom), max(-startInset.right, insetOffset.right))
                insetOffset.bottom = offset * ratio
                insetOffset.right = offset
            }
        // Edge regions
        case .top:
            insetOffset.top = keepAspectRatio ? 0 : min(translation.y, minHeight)
        case .bottom:
            insetOffset.bottom = keepAspectRatio ? 0 : min(-translation.y, minHeight)
        case .left:
            insetOffset.left = keepAspectRatio ? 0 : min(translation.x, minWidth)
        case .right:
            insetOffset.right = keepAspectRatio ? 0 : min(-translation.x, minWidth)
        // Center region
        case .center:
            let moveVertical = clamp(translation.y, min: -startInset.top, max: startInset.bottom)
            let moveHorizontal = clamp(translation.x, min: -startInset.left, max: startInset.right)

            insetOffset.top = moveVertical
            insetOffset.left = moveHorizontal
            insetOffset.right = -moveHorizontal
            insetOffset.bottom = -moveVertical
        }

        cropInsets = startInset.adding(edgeInset: insetOffset).clipped()
    }

    func reset(to insets: UIEdgeInsets?) {
        guard let insets = insets else { return }

        cropInsets = insets
    }
}
