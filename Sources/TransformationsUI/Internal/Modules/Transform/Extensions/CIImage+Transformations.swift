//
//  CIImage+Transformations.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension CIImage {
    /// Transforms an image using a given `RenderNodeTransform`.
    ///
    /// - Parameter type: The `RenderNodeTransform` to apply.
    ///
    func transformed(using type: RenderNodeTransform) -> CIImage? {
        switch type {
        case .crop(let insets, let cropType):
            switch cropType {
            case .rect:
                return cropped(by: insets)
            case .circle:
                return circled(by: insets)
            }
        case .rotate:
            return rotated()
        }
    }
}

private extension CIImage {
    func rotated() -> CIImage? {
        let transform = orientationTransform(for: .left)
        return transformed(by: transform)
    }

    func cropped(by insets: UIEdgeInsets) -> CIImage? {
        let transform = coordinatesTransform(rect: extent)
        let rect = extent.applying(transform).inset(by: insets).applying(transform)

        return cropped(to: rect)
    }

    func circled(by insets: UIEdgeInsets) -> CIImage? {
        guard let croppedCIImage = cropped(by: insets) else { return nil }

        let rect = croppedCIImage.extent
        let radius = min(rect.width, rect.height) / 2

        let alpha1 = CIColor(red: 0, green: 0, blue: 0, alpha: 1)
        let alpha0 = CIColor(red: 0, green: 0, blue: 0, alpha: 0)
        let croppedCenter = CIVector(x: rect.midX, y: rect.midY)

        let radialGradientFilter = CIFilter(name: "CIRadialGradient", parameters: ["inputRadius0": radius - 0.5,
                                                                                   "inputRadius1": radius + 0.5,
                                                                                   "inputColor0": alpha1,
                                                                                   "inputColor1": alpha0,
                                                                                   kCIInputCenterKey: croppedCenter])

        guard let circledImage = radialGradientFilter?.outputImage else { return nil }

        let compositingFilter = CIFilter(name: "CISourceInCompositing", parameters: [kCIInputImageKey: croppedCIImage,
                                                                                     kCIInputBackgroundImageKey: circledImage])

        return compositingFilter?.outputImage
    }

    func coordinatesTransform(rect: CGRect) -> CGAffineTransform {
        return CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -rect.height)
    }
}
