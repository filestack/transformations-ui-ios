//
//  ObjectRenderNode+ApplyTransform.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 9/12/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation
import CoreGraphics

extension ObjectRenderNode {
    func apply(transform: RenderNodeTransform) {
        guard let groupView = (group as? ViewableNode)?.view else { return }

        switch transform {
        case .flip:
            let transform = CGAffineTransform(scaleX: -1, y: 1)
            // Update center
            center = CGPoint(x: groupView.bounds.width - view.center.x, y: view.center.y)
            // Apply transform to `textLayer`
            self.transform = self.transform.concatenating(transform)
        case .flop:
            let transform = CGAffineTransform(scaleX: 1, y: -1)
            // Update center
            center = CGPoint(x: view.center.x, y: groupView.bounds.height - view.center.y)
            // Apply transform to `textLayer`
            self.transform = self.transform.concatenating(transform)
        case .rotate(let clockwise):
            let radians = (clockwise ? 1 : -1) * CGFloat.pi / 2
            let transform = CGAffineTransform(rotationAngle: radians)

            // Rotate layer
            self.transform = self.transform.concatenating(transform)

            // Update center
            if clockwise {
                center = CGPoint(x: groupView.bounds.width - view.center.y, y: view.center.x)
            } else {
                center = CGPoint(x: view.center.y, y: groupView.bounds.height - view.center.x)
            }
        case .resize(let ratio):
            // Update center and bounds
            center = center.scaledBy(x: ratio.width, y: ratio.height)
            bounds.size = bounds.size.scaledBy(x: ratio.width, y: ratio.height)
        case .crop(let insets, _):
            let transform = CGAffineTransform(translationX: -insets.left, y: -insets.top)

            // Update center
            center = center.applying(transform)
        }
    }
}
