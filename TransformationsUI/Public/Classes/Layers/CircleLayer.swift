//
//  CropLayer.swift
//  TransformationsUI
//
//  Created by Mihály Papp on 12/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

class CircleCropLayer: CALayer {
    var imageFrame = CGRect.zero {
        didSet { updateSublayers() }
    }

    var circleRadius: CGFloat = 0 {
        didSet { updateSublayers() }
    }

    var circleCenter = CGPoint.zero {
        didSet { updateSublayers() }
    }

    override init() {
        super.init()

        addSublayer(outsideLayer)
        addSublayer(circleLayer)
        addSublayer(leftHandleLayer)
        addSublayer(rightHandleLayer)
        addSublayer(topHandleLayer)
        addSublayer(bottomHandleLayer)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var handleRadius: CGFloat = 9

    private lazy var circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.path = circlePath
        layer.lineWidth = 3
        layer.strokeColor = UIColor.white.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor

        return layer
    }()

    private lazy var outsideLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.path = outsidePath
        layer.fillRule = .evenOdd
        layer.backgroundColor = UIColor.black.cgColor
        layer.opacity = 0.7

        return layer
    }()

    private lazy var leftHandleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.path = handlePath(for: .left)
        layer.strokeColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.white.cgColor
        layer.backgroundColor = UIColor.clear.cgColor

        return layer
    }()

    private lazy var rightHandleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.path = handlePath(for: .right)
        layer.strokeColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.white.cgColor
        layer.backgroundColor = UIColor.clear.cgColor

        return layer
    }()

    private lazy var topHandleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.path = handlePath(for: .top)
        layer.strokeColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.white.cgColor
        layer.backgroundColor = UIColor.clear.cgColor

        return layer
    }()

    private lazy var bottomHandleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.path = handlePath(for: .bottom)
        layer.strokeColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.white.cgColor
        layer.backgroundColor = UIColor.clear.cgColor

        return layer
    }()
}

/// :nodoc:
private extension CircleCropLayer {
    enum Side {
        case top
        case bottom
        case left
        case right
    }

    var circleRect: CGRect {
        let origin = CGPoint(x: circleCenter.x - circleRadius, y: circleCenter.y - circleRadius)

        return CGRect(origin: origin, size: CGSize(width: circleRadius * 2, height: circleRadius * 2))
    }

    var circlePath: CGPath {
        let path = UIBezierPath(ovalIn: circleRect)

        return path.cgPath
    }

    var outsidePath: CGPath {
        let path = UIBezierPath(ovalIn: circleRect)

        path.append(UIBezierPath(rect: imageFrame))

        return path.cgPath
    }

    func handlePath(for side: Side) -> CGPath {
        let circleRect = self.circleRect
        let origin: CGPoint

        switch side {
        case .top:
            origin = CGPoint(x: circleRect.midX - handleRadius, y: circleRect.maxY - handleRadius)
        case .bottom:
            origin = CGPoint(x: circleRect.midX - handleRadius, y: circleRect.minY - handleRadius)
        case .left:
            origin = CGPoint(x: circleRect.minX - handleRadius, y: circleRect.midY - handleRadius)
        case .right:
            origin = CGPoint(x: circleRect.maxX - handleRadius, y: circleRect.midY - handleRadius)
        }

        let rect = CGRect(origin: origin, size: CGSize(width: handleRadius * 2, height: handleRadius * 2))
        let path = UIBezierPath(ovalIn: rect)

        return path.cgPath
    }

    func updateSublayers() {
        circleLayer.path = circlePath
        outsideLayer.path = outsidePath
        leftHandleLayer.path = handlePath(for: .left)
        rightHandleLayer.path = handlePath(for: .right)
        topHandleLayer.path = handlePath(for: .top)
        bottomHandleLayer.path = handlePath(for: .bottom)
    }
}
