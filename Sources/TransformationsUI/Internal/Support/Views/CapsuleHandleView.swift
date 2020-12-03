//
//  CapsuleHandleView.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 27/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

class CapsuleHandleView: UIView, Draggable {
    var capsuleLayer: CAShapeLayer!
    let handleType: HandleType
    let tolerance: CGFloat

    // MARK: - Lifecycle

    init(center: CGPoint, size: CGSize, tolerance: CGFloat = 0, type handleType: HandleType) {
        self.handleType = handleType
        self.tolerance = tolerance

        let sizeWithTolerance = size.adding(width: tolerance * 2, height: tolerance * 2)

        let frame = CGRect(origin: center, size: sizeWithTolerance)
            .offsetBy(dx: -sizeWithTolerance.width / 2, dy: -sizeWithTolerance.height / 2)

        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Overrides

extension CapsuleHandleView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard capsuleLayer == nil else { return }

        capsuleLayer = CAShapeLayer()

        capsuleLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: tolerance, dy: tolerance),
                                         byRoundingCorners: .allCorners,
                                         cornerRadii: CGSize(width: 6, height: 6)).cgPath

        capsuleLayer.fillColor = UIColor.white.cgColor
        capsuleLayer.strokeColor = UIColor.black.cgColor
        capsuleLayer.lineWidth = 2

        layer.addSublayer(capsuleLayer)
    }
}
