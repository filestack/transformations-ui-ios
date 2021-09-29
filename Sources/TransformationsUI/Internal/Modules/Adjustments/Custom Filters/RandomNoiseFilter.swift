//
//  RandomNoiseFilter.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 27/9/21.
//  Copyright © 2021 Filestack. All rights reserved.
//

import CoreImage

class RandomNoiseFilter: CIFilter {
    // MARK: - Input Properties

    @objc dynamic var inputImage: CIImage?
    @objc dynamic var noiseAmount: Float = 1

    static var filterKernel: CIKernel {
        let url = Bundle.module.url(forResource: "RandomNoise",
                                    withExtension: "cikernel")!

        let kernelString = try! String(contentsOf: url)

        return CIKernel(source: kernelString)!
    }

    // MARK: - Property Overrides

    override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return inputImage
        }

        return RandomNoiseFilter.filterKernel.apply(extent: inputImage.extent,
                                           roiCallback: { _, destRect in
            return destRect
        },
                                           arguments: [inputImage.clampedToExtent(), noiseAmount])
    }
}

extension RandomNoiseFilter {
    // MARK: - Filter Constructor

    class Vendor: NSObject, CIFilterConstructor {
        public static let FilterName = "RandomNoise"

        static func registerFilters() {
            RandomNoiseFilter.registerName(FilterName, constructor: Vendor(), classAttributes: [:])
        }

        func filter(withName name: String) -> CIFilter? {
            return RandomNoiseFilter()
        }
    }
}
