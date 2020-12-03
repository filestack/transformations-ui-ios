//
//  UIView+RenderToImage.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/11/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

extension UIView {
    func renderToImage(afterScreenUpdates: Bool) -> UIImage {
        let rendererFormat = UIGraphicsImageRendererFormat.default()

        rendererFormat.opaque = false
        rendererFormat.scale = contentScaleFactor

        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: rendererFormat)

        return renderer.image { (ctx) in
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }
    }
}
