//
//  CircularHandleView.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 30/03/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

class CircularHandleView: UIView, Draggable {
    var circleLayer: CAShapeLayer!
    let radius: CGFloat
    let tolerance: CGFloat
    let handleType: HandleType

    // MARK: - Lifecycle

    init(center: CGPoint, radius: CGFloat, tolerance: CGFloat = 0, type handleType: HandleType) {
        self.radius = radius
        self.tolerance = tolerance
        self.handleType = handleType

        let frame = CGRect(origin: CGPoint(x: center.x - (radius), y: center.y - (radius)),
                           size: CGSize(width: radius * 2, height: radius * 2)).insetBy(dx: -tolerance, dy: -tolerance)

        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Overrides

extension CircularHandleView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard circleLayer == nil else { return }

        circleLayer = CAShapeLayer()

        circleLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: tolerance, dy: tolerance),
                                        cornerRadius: radius).cgPath

        circleLayer.fillColor = UIColor.systemBlue.cgColor
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.lineWidth = 1

        layer.addSublayer(circleLayer)
    }
}
