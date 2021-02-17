//
//  CIImage+Transformations.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 05/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension CIImage {
    /// Transforms an image using a given `TransformType`.
    ///
    /// - Parameter type: The `TransformType` to apply.
    ///
    func transformed(using type: RenderNodeTransform) -> CIImage? {
        switch type {
        case .flip:
            return flipped()
        case .flop:
            return flopped()
        case .rotate(let clockwise):
            return rotated(clockwise: clockwise)
        case .resize(let ratio):
            let size = extent.size.scaledBy(x: ratio.width, y: ratio.height)

            return resized(to: size)
        case .crop(let insets, let cropType):
            switch cropType {
            case .rect:
                return cropped(by: insets)
            case .circle:
                return circled(by: insets)
            }
        }
    }

    func squareCropped() -> CIImage? {
        var extent = self.extent

        let minSide = min(extent.width, extent.height)

        extent.origin.x += (extent.width - minSide) / 2
        extent.origin.y += (extent.height - minSide) / 2
        extent.size.width = minSide
        extent.size.height = minSide

        return cropped(to: extent)
    }

    /// Resize the image to a given size using an intermediate overextended image.
    ///
    /// - Parameters:
    ///   - size: A `CGSize` with the desired output size.
    ///   - inset: A `CGFloat` with the inset amount.
    func resized(to size: CGSize) -> CIImage? {
        let scaleX = size.width / extent.size.width
        let scaleY = size.height / extent.size.height

        let outputImage = applyingFilter("CILanczosScaleTransform",
                                         parameters: [kCIInputScaleKey: scaleY,
                                                      kCIInputAspectRatioKey: scaleX / scaleY])

        if outputImage.extent.size == size.rounded() {
            return outputImage
        } else {
            // We didn't get an exact match, use alternative resize.
            return resizedOverextended(to: size)
        }
    }
}

private extension CIImage {
    func resizedOverextended(to size: CGSize, inset: CGFloat = -2) -> CIImage? {
        let scaleX = size.width / extent.size.width
        let scaleY = size.height / extent.size.height

        let overExtendedImage = clampedToExtent()
            .cropped(to: extent.insetBy(dx: inset, dy: inset))

        let outputImage = overExtendedImage.applyingFilter("CILanczosScaleTransform",
                                                           parameters: [kCIInputScaleKey: scaleY,
                                                                        kCIInputAspectRatioKey: scaleX / scaleY])

        let outSize = outputImage.extent.size

        var rect = outputImage.extent.insetBy(dx: ((outSize.width - size.width) * 0.5),
                                              dy: ((outSize.height - size.height) * 0.5))

        rect.origin = rect.origin.rounded()
        rect.size = size

        return outputImage.cropped(to: rect)
    }

    func flipped() -> CIImage? {
        return transformed(by: CGAffineTransform(scaleX: -1, y: 1))
    }

    func flopped() -> CIImage? {
        return transformed(by: CGAffineTransform(scaleX: 1, y: -1))
    }

    func rotated(clockwise: Bool) -> CIImage? {
        let transform = orientationTransform(for: clockwise ? .right : .left)
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
