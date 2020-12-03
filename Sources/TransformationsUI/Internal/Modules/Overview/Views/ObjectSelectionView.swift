//
//  SelectionAreaView.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 2/28/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

class ObjectSelectionView: UIView {
    // MARK: - Internal Properties

    var selectionBackgroundColor: CGColor = UIColor.systemBlue.cgColor
    var handleRadius: CGFloat = 10
    var tolerance: CGFloat = 10

    var handleViews: [Draggable] {
        return subviews.compactMap { $0 as? Draggable }
    }

    // MARK: - Private Properties

    // Scale Handle
    private lazy var scaleHandle: ImageHandleView = {
        ImageHandleView(center: CGPoint(x: bounds.maxX, y: bounds.maxY),
                        image: UIImage.fromBundle("icon-scale-object"),
                        tolerance: tolerance,
                        type: .scale)
    }()

    // Rotate Handle
    private lazy var rotateHandle: ImageHandleView = {
        ImageHandleView(center: CGPoint(x: bounds.maxX, y: bounds.minY),
                        image: UIImage.fromBundle("icon-rotate-object"),
                        tolerance: tolerance,
                        type: .rotate)
    }()

    // Bottom Handle
    private lazy var bottomHandle: CapsuleHandleView = {
        CapsuleHandleView(center: CGPoint(x: bounds.midX, y: bounds.maxY),
                          size: CGSize(width: handleRadius * 4, height: handleRadius),
                          tolerance: tolerance,
                          type: .bottom)
    }()

    // Right Handle
    private lazy var rightHandle: CapsuleHandleView = {
        CapsuleHandleView(center: CGPoint(x: bounds.maxX, y: bounds.midY),
                          size: CGSize(width: handleRadius, height: handleRadius * 4),
                          tolerance: tolerance,
                          type: .right)
    }()

    // Border Layer
    private lazy var borderLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        let shapeRect = CGRect(origin: .zero, size: bounds.size)

        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [4, 4]
        shapeLayer.path = UIBezierPath(rect: shapeRect).cgPath

        return shapeLayer
    }()

    // Alt border Layer
    private lazy var altBorderLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        let shapeRect = CGRect(origin: .zero, size: bounds.size)

        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor.copy(alpha: 0.1)
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPhase = 3
        shapeLayer.lineDashPattern = [4, 4]
        shapeLayer.path = UIBezierPath(rect: shapeRect).cgPath

        return shapeLayer
    }()

    // MARK: - View Overrides

    override var bounds: CGRect {
        didSet { updateLayersAndSubviews() }
    }

    // MARK: - Lifecycle

    init() {
        super.init(frame: .zero)

        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ObjectSelectionView {
    func dragHandle(at point: CGPoint) -> HandleType? {
        // Detect dragging from a side or corner.
        var handle = (handleViews.first { $0.frame.contains(point) })?.handleType
        // No matches? Detect dragging from center.
        if handle == .none, bounds.contains(point) {
            handle = .center
        }

        return handle
    }
}

// MARK: - Private Functions

private extension ObjectSelectionView {
    func updateLayersAndSubviews() {
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)

        // Add borders, if required.
        if borderLayer.superlayer == nil { layer.addSublayer(borderLayer) }
        if altBorderLayer.superlayer == nil { layer.addSublayer(altBorderLayer) }

        // Update border layer.
        borderLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        borderLayer.bounds = CGRect(origin: .zero, size: bounds.size)
        borderLayer.path = UIBezierPath(rect: borderLayer.bounds).cgPath

        // Update alt border layer.
        altBorderLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        altBorderLayer.bounds = CGRect(origin: .zero, size: bounds.size)
        altBorderLayer.path = UIBezierPath(rect: borderLayer.bounds).cgPath

        // Add handles, if required.
        if scaleHandle.superview == nil { addSubview(scaleHandle) }
        if rotateHandle.superview == nil { addSubview(rotateHandle) }
        if bottomHandle.superview == nil { addSubview(bottomHandle) }
        if rightHandle.superview == nil { addSubview(rightHandle) }

        // Update handles.
        scaleHandle.center = CGPoint(x: bounds.maxX, y: bounds.maxY)
        rotateHandle.center = CGPoint(x: bounds.maxX, y: bounds.minY)
        bottomHandle.center = CGPoint(x: bounds.midX, y: bounds.maxY)
        rightHandle.center = CGPoint(x: bounds.maxX, y: bounds.midY)

        CATransaction.commit()
    }
}
