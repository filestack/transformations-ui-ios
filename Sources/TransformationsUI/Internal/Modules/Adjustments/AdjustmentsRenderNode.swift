//
//  AdjustmentsRenderNode.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 21/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

class AdjustmentsRenderNode: RenderNode, RenderGroupChildNode & IONode {
    var group: RenderGroupNode?

    var inputImage: CIImage = CIImage() {
        didSet { applyAdjustments() }
    }

    var outputImage: CIImage { renderedImage ?? inputImage }

    var renderedImage: CIImage? = nil {
        didSet { group?.nodeChanged(node: self) }
    }

    var blurAmount: Double = 0.0 {
        didSet { applyAdjustments() }
    }

    var contrast: Double = 1.0 {
        didSet { applyAdjustments() }
    }

    var brightness: Double = 0.0 {
        didSet { applyAdjustments() }
    }

    var gamma: CIVector = CIVector(x: 0, y: 0, z: 0) {
        didSet { applyAdjustments() }
    }

    var hueRotationAngle: Double = 0.0 {
        didSet { applyAdjustments() }
    }

    required init(uuid: UUID? = nil) {
        super.init(uuid: uuid)

        RGBGammaAdjustFilter.Vendor.registerFilters()
    }
}

extension AdjustmentsRenderNode {
    // MARK: - Private Functions

    private func applyAdjustments() {
        let shortestSide = Double(min(inputImage.extent.size.width, inputImage.extent.size.height))

        renderedImage = inputImage
            .clampedToExtent()
            .applyingGaussianBlur(sigma: blurAmount * shortestSide)
            .applyingFilter("CIColorControls", parameters: [
                "inputBrightness" : brightness,
                "inputContrast": contrast
            ])
            .applyingFilter("RGBGammaAdjust", parameters: [
                "inputGamma": gamma
            ])
            .applyingFilter("CIHueAdjust", parameters: [
                "inputAngle" : hueRotationAngle
            ])
            .applyingFilter("CIBlendWithAlphaMask", parameters: [
                "inputMaskImage": inputImage
            ])
    }
}

extension AdjustmentsRenderNode: Snapshotable {
    public func snapshot() -> Snapshot {
        return [
            "blurAmount": blurAmount,
            "contrast": contrast,
            "brightness": brightness,
            "gamma": gamma,
            "hueRotationAngle": hueRotationAngle
        ]
    }

    public func restore(from snapshot: Snapshot) {
        for item in snapshot {
            switch item {
            case let("blurAmount", blurAmount as Double):
                self.blurAmount = blurAmount
            case let("contrast", contrast as Double):
                self.contrast = contrast
            case let("brightness", brightness as Double):
                self.brightness = brightness
            case let("gamma", gamma as CIVector):
                self.gamma = gamma
            case let("hueRotationAngle", hueRotation as Double):
                self.hueRotationAngle = hueRotation
            default:
                break
            }
        }
    }
}
