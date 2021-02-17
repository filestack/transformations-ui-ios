//
//  RectCropGesturesHandler.swift
//  TransformationsUI
//
//  Created by Mihály Papp on 12/07/2018.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import AVFoundation.AVUtilities

public protocol RectCropGesturesHandlerDelegate: EditDataSource {
    func rectCropChanged(_ handler: RectCropGesturesHandler)
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

    /// Determines whether aspect ratio should be preserved during cropping.
    public var keepAspectRatio: Bool = false {
        didSet { reset() }
    }

    /// Determines the aspect ratio enforced for cropping, if `keepAspectRatio` is enabled.
    public var aspectRatio: CGSize = .zero {
        didSet { reset() }
    }

    /// Determines whether initiating a drag from the top, bottom, left and right sides is allowed.
    ///
    /// When disabled, drag will be started based on the closest detected sector that excludes the side sectors.
    public var allowDraggingFromSides: Bool {
        didSet { updateAvailableSectors() }
    }

    // MARK: - Private Properties

    private var beginInset: UIEdgeInsets?
    private var movingSector: Sector?
    private var availableSectors: [Sector] = Sector.all
    private lazy var relativeCropInsets = UIEdgeInsets.zero

    // MARK: - Lifecycle

    public init(delegate: RectCropGesturesHandlerDelegate, allowDraggingFromSides: Bool = true) {
        self.delegate = delegate
        self.allowDraggingFromSides = allowDraggingFromSides

        updateAvailableSectors()
    }
}

// MARK: - Public Functions

public extension RectCropGesturesHandler {
    func reset() {
        if keepAspectRatio {
            let insets = aspectCorrectedInsets(frame: delegate?.virtualFrame ?? .zero)

            relativeCropInsets = keepAspectRatio ? relativeInsets(from: insets) : .zero
        } else {
            relativeCropInsets = .zero
        }
    }

    func handlePanGesture(recognizer: UIPanGestureRecognizer, in targetView: UIView) {
        let translation = recognizer.translation(in: targetView)
        let origin = recognizer.location(in: targetView).movedBy(x: -translation.x, y: -translation.y)

        handle(translation: translation, from: origin, forState: recognizer.state)
    }
}

// MARK: - Private Functions and Computed Properties

private extension RectCropGesturesHandler {
    typealias RelativeInsets = (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)

    enum Sector {
        case topLeft, topRight, bottomLeft, bottomRight, center, top, bottom, left, right
        static var all: [Sector] = [.topLeft, .topRight, .bottomLeft, .bottomRight, .center, .top, .bottom, .left, .right]
    }

    var cropInsets: UIEdgeInsets {
        get {
            return edgeInsets(from: relativeCropInsets)
        }

        set {
            relativeCropInsets = relativeInsets(from: newValue)
            delegate?.rectCropChanged(self)
        }
    }

    func updateAvailableSectors() {
        if allowDraggingFromSides {
            availableSectors = Sector.all
        } else {
            availableSectors = [.topLeft, .topRight, .bottomLeft, .bottomRight, .center]
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
            movingSector = closestSector(to: adjustedPoint)
            move(by: translation)
        case .changed:
            move(by: translation)
        case .ended:
            move(by: translation)
            beginInset = nil
        case .cancelled, .failed:
            reset(to: edgeInsets(from: beginInset))
        case .possible:
            fallthrough
        @unknown default:
            return
        }
    }

    func closestSector(to point: CGPoint) -> Sector? {
        typealias SectorDistance = (sector: Sector, distance: CGFloat)

        let sectorByDistance = availableSectors.map {
            SectorDistance(
                sector: $0,
                distance: dragLocation(for: $0).distance(to: point)
            )
        }

        return sectorByDistance
            .sorted { $0.distance < $1.distance }
            .first?.sector
    }

    func dragLocation(for sector: Sector) -> CGPoint {
        guard let delegate = delegate else { return .zero }

        let insets = cropInsets

        let top: CGFloat = insets.top
        let bottom: CGFloat = delegate.virtualFrame.height - insets.bottom
        let left: CGFloat = insets.left
        let right: CGFloat = delegate.virtualFrame.width - insets.right

        switch sector {
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

    func move(by translation: CGPoint) {
        guard let delegate = delegate, let beginInset = beginInset, let movingSector = movingSector else { return }

        let startInset = edgeInsets(from: beginInset)
        var insetOffset = UIEdgeInsets.zero
        let minHeight = delegate.virtualFrame.height - startInset.top - startInset.bottom
        let minWidth = delegate.virtualFrame.width - startInset.left - startInset.right

        switch movingSector {
        // Corner sectors
        case .topLeft:
            insetOffset.top = min(translation.y, minHeight)
            insetOffset.left = min(translation.x, minWidth)
        case .topRight:
            insetOffset.top = min(translation.y, minHeight)
            insetOffset.right = min(-translation.x, minWidth)
        case .bottomLeft:
            insetOffset.bottom = min(-translation.y, minHeight)
            insetOffset.left = min(translation.x, minWidth)
        case .bottomRight:
            insetOffset.bottom = min(-translation.y, minHeight)
            insetOffset.right = min(-translation.x, minWidth)
        // Center sector
        case .center:
            let moveVertical = clamp(translation.y, min: -startInset.top, max: startInset.bottom)
            let moveHorizontal = clamp(translation.x, min: -startInset.left, max: startInset.right)

            insetOffset.top = moveVertical
            insetOffset.left = moveHorizontal
            insetOffset.right = -moveHorizontal
            insetOffset.bottom = -moveVertical
        // Unhandled sectors
        default:
            break
        }

        let endInsets = startInset.adding(insets: insetOffset).clipped()

        if keepAspectRatio {
            cropInsets = aspectCorrectedInsets(using: endInsets,
                                               startInsets: startInset,
                                               frame: delegate.virtualFrame,
                                               sector: movingSector)
        } else {
            cropInsets = endInsets
        }
    }

    func aspectCorrectedInsets(using insets: UIEdgeInsets = .zero, frame: CGRect) -> UIEdgeInsets {
        let croppedRect = frame.inset(by: insets)
        let aspectAdjustedFrame = AVMakeRect(aspectRatio: aspectRatio, insideRect: croppedRect)

        let insets = UIEdgeInsets(top: abs(frame.minY - aspectAdjustedFrame.minY),
                                  left: abs(frame.minX - aspectAdjustedFrame.minX),
                                  bottom: abs(frame.maxY - aspectAdjustedFrame.maxY),
                                  right: abs(frame.maxX - aspectAdjustedFrame.maxX))

        return insets
    }

    func aspectCorrectedInsets(using insets: UIEdgeInsets, startInsets: UIEdgeInsets, frame: CGRect, sector: Sector) -> UIEdgeInsets {
        var correctedInsets = aspectCorrectedInsets(using: insets, frame: frame)

        switch movingSector {
        case .topLeft:
            correctedInsets.top -= startInsets.bottom - correctedInsets.bottom
            correctedInsets.left -= startInsets.right - correctedInsets.right
            correctedInsets.bottom = startInsets.bottom
            correctedInsets.right = startInsets.right
        case .topRight:
            correctedInsets.top -= startInsets.bottom - correctedInsets.bottom
            correctedInsets.right -= startInsets.left - correctedInsets.left
            correctedInsets.bottom = startInsets.bottom
            correctedInsets.left = startInsets.left
        case .bottomLeft:
            correctedInsets.bottom -= startInsets.top - correctedInsets.top
            correctedInsets.left -= startInsets.right - correctedInsets.right
            correctedInsets.top = startInsets.top
            correctedInsets.right = startInsets.right
        case .bottomRight:
            correctedInsets.bottom -= startInsets.top - correctedInsets.top
            correctedInsets.right -= startInsets.left - correctedInsets.left
            correctedInsets.top = startInsets.top
            correctedInsets.left = startInsets.left
        default:
            break
        }

        return correctedInsets.clipped()
    }

    func reset(to insets: UIEdgeInsets?) {
        guard let insets = insets else { return }

        cropInsets = insets
    }
}
