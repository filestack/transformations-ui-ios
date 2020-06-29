//
//  CIImage+Transformations.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

extension CIImage {
    /// Returns a 90 degree-rotated `CIImage`.
    ///
    /// - Parameter clockwise: If true, image is rotated clockwise, otherwise it is rotated anticlockwise.
    ///
    func rotated(clockwise: Bool) -> CIImage? {
        let transform = orientationTransform(for: clockwise ? .right : .left)
        return transformed(by: transform)
    }

    /// Returns a cropped `CIImage`.
    ///
    /// - Parameter insets: Specifies how much should be inset on each side of the rect.
    ///
    func cropped(by insets: UIEdgeInsets) -> CIImage? {
        let transform = coordinatesTransform(rect: extent)
        let rect = extent.applying(transform).inset(by: insets).applying(transform)

        return cropped(to: rect)
    }

    /// Returns a circle-cropped `CIImage`.
    ///
    /// - Parameter center: Circle's center point.
    /// - Parameter radius: Circle's radius.
    /// - Parameter transformed: Whether to transform UIKit coordinates into Core Image coordinates. Defaults to false.
    ///
    func circled(center: CGPoint, radius: CGFloat) -> CIImage? {
        let transform = coordinatesTransform(rect: extent)
        let tCenter = center.applying(transform)

        let origin = CGPoint(x: extent.minX + (tCenter.x - radius),
                             y: extent.minY + (tCenter.y - radius)).rounded()

        let rect = CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2).rounded())

        let transformedCIImage = cropped(to: rect)

        let alpha1 = CIColor(red: 0, green: 0, blue: 0, alpha: 1)
        let alpha0 = CIColor(red: 0, green: 0, blue: 0, alpha: 0)
        let croppedCenter = CIVector(x: rect.midX, y: rect.midY)

        let radialGradientFilter = CIFilter(name: "CIRadialGradient", parameters: ["inputRadius0": radius,
                                                                                   "inputRadius1": radius + 1,
                                                                                   "inputColor0": alpha1,
                                                                                   "inputColor1": alpha0,
                                                                                   kCIInputCenterKey: croppedCenter])

        guard let circledImage = radialGradientFilter?.outputImage else { return nil }

        let compositingFilter = CIFilter(name: "CISourceInCompositing", parameters: [kCIInputImageKey: transformedCIImage,
                                                                                     kCIInputBackgroundImageKey: circledImage])

        return compositingFilter?.outputImage
    }

    // MARK: - Private Functions

    private func coordinatesTransform(rect: CGRect) -> CGAffineTransform {
        return CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -rect.height)
    }
}
