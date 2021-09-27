//
//  RGBGammaFilter.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 25/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import CoreImage

class RGBGammaAdjustFilter: CIFilter {
    // MARK: - Input Properties

    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputGamma: CIVector = CIVector(x: 0, y: 0, z: 0)

    // MARK: - Property Overrides

    override var outputImage: CIImage? {
        inputImage?.applyingFilter("CIColorMatrix", parameters: ["inputBiasVector": inputGamma])
    }

    override var attributes: [String : Any] {
      return [
        kCIAttributeFilterDisplayName: "RGB Gamma Adjust",

        "inputImage": [
            kCIAttributeIdentity: 0,
            kCIAttributeClass: "CIImage",
            kCIAttributeDisplayName: "Image",
            kCIAttributeType: kCIAttributeTypeImage
        ],

        "inputGamma": [
            kCIAttributeIdentity: 0,
            kCIAttributeClass: "CIVector",
            kCIAttributeDisplayName: "RGB Gamma",
            kCIAttributeType: kCIAttributeTypePosition3
        ]
      ]
    }
}

extension RGBGammaAdjustFilter {
    // MARK: - Filter Constructor

    class Vendor: NSObject, CIFilterConstructor {
        public static let FilterName = "RGBGammaAdjust"

        static func registerFilters() {
            RGBGammaAdjustFilter.registerName(FilterName, constructor: Vendor(), classAttributes: [:])
        }

        func filter(withName name: String) -> CIFilter? {
            return RGBGammaAdjustFilter()
        }
    }
}
