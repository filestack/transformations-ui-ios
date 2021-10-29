//
//  RectCropLayer.swift
//  TransformationsUI
//
//  Created by Mihály Papp on 12/07/2018.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

public class RectCropLayer: CALayer {
    // MARK: - Public Properties

    public var imageFrame = CGRect.zero {
        didSet { updateSublayers() }
    }

    public var cropRect = CGRect.zero {
        didSet { updateSublayers() }
    }

    // MARK: - Private Properties

    private var handleRadius: CGFloat = Constants.Misc.cropHandleRadius
    private var lineThickness: CGFloat = Constants.Misc.cropLineThickness

    private lazy var outsideLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.path = outsidePath
        layer.fillRule = .evenOdd
        layer.fillColor = Constants.Color.background.cgColor
        layer.opacity = Constants.Misc.cropOutsideOpacity

        return layer
    }()

    private lazy var gridLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.path = gridPath
        layer.lineWidth = lineThickness
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor

        return layer
    }()

    private lazy var bottomLeftHandleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.path = handlePath(for: .bottomLeft)
        layer.strokeColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.white.cgColor

        return layer
    }()

    private lazy var bottomRightHandleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.path = handlePath(for: .bottomRight)
        layer.strokeColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.white.cgColor

        return layer
    }()

    private lazy var topLeftHandleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.path = handlePath(for: .topLeft)
        layer.strokeColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.white.cgColor

        return layer
    }()

    private lazy var topRightHandleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.path = handlePath(for: .topRight)
        layer.strokeColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.white.cgColor

        return layer
    }()

    // MARK: - Lifecycle

    public override init() {
        super.init()

        addSublayer(outsideLayer)
        addSublayer(gridLayer)
        addSublayer(bottomLeftHandleLayer)
        addSublayer(bottomRightHandleLayer)
        addSublayer(topLeftHandleLayer)
        addSublayer(topRightHandleLayer)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Functions

public extension RectCropLayer {
    func updateColors() {
        outsideLayer.fillColor = Constants.Color.background.cgColor
    }
}

// MARK: - Private Functions and Computed Properties

private extension RectCropLayer {
    enum Corner {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    var outsidePath: CGPath {
        let path = UIBezierPath(rect: cropRect)

        path.append(UIBezierPath(rect: imageFrame))

        return path.cgPath
    }

    var gridPath: CGPath {
        let gridWidth = cropRect.size.width / 3
        let gridHeight = cropRect.size.height / 3
        let path = UIBezierPath(rect: cropRect)

        path.move(to: cropRect.origin.movedBy(x: gridWidth))
        path.addLine(to: path.currentPoint.movedBy(y: gridHeight * 3))
        path.move(to: cropRect.origin.movedBy(x: gridWidth * 2))
        path.addLine(to: path.currentPoint.movedBy(y: gridHeight * 3))
        path.move(to: cropRect.origin.movedBy(y: gridHeight))
        path.addLine(to: path.currentPoint.movedBy(x: gridWidth * 3))
        path.move(to: cropRect.origin.movedBy(y: gridHeight * 2))
        path.addLine(to: path.currentPoint.movedBy(x: gridWidth * 3))

        return path.cgPath
    }

    func handlePath(for side: Corner) -> CGPath {
        let cropRect = self.cropRect
        let origin: CGPoint

        switch side {
        case .topLeft:
            origin = CGPoint(x: cropRect.minX - handleRadius, y: cropRect.maxY - handleRadius)
        case .topRight:
            origin = CGPoint(x: cropRect.maxX - handleRadius, y: cropRect.maxY - handleRadius)
        case .bottomLeft:
            origin = CGPoint(x: cropRect.minX - handleRadius, y: cropRect.minY - handleRadius)
        case .bottomRight:
            origin = CGPoint(x: cropRect.maxX - handleRadius, y: cropRect.minY - handleRadius)
        }

        let rect = CGRect(origin: origin, size: CGSize(width: handleRadius * 2, height: handleRadius * 2))
        let path = UIBezierPath(ovalIn: rect)

        return path.cgPath
    }

    func updateSublayers() {
        outsideLayer.path = outsidePath
        gridLayer.path = gridPath
        topLeftHandleLayer.path = handlePath(for: .topLeft)
        topRightHandleLayer.path = handlePath(for: .topRight)
        bottomLeftHandleLayer.path = handlePath(for: .bottomLeft)
        bottomRightHandleLayer.path = handlePath(for: .bottomRight)
    }
}
