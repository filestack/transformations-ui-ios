//
//  RingButton.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 17/08/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

class RingButton: UIButton {
    var color: UIColor! = .white {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        UIGraphicsPushContext(context)

        context.setFillColor(color.cgColor)
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2

        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: radius,
                                      startAngle: 0,
                                      endAngle: CGFloat.pi * 2,
                                      clockwise: true)
        
        circlePath.fill()

        context.setBlendMode(.destinationOut)

        let maskPath = UIBezierPath(arcCenter: center,
                                    radius: radius * 0.75,
                                    startAngle: 0,
                                    endAngle: CGFloat.pi * 2,
                                    clockwise: true)
        
        maskPath.fill()

        context.setBlendMode(.normal)
        
        UIGraphicsPopContext()
    }
}
