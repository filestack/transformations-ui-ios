//
//  UIImage+CIImageTransformations.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 7/4/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension UIImage {
    /// For `CIImage` backed `UIImage`s, this function returns an equivalent `CGImage` backed `UIImage`, whether as,
    /// for already `CGImage` backed `UIImage`s, it returns `self`.
    func cgImageBackedCopy() -> UIImage? {
        guard let ciImage = ciImage else { return self }
        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }

    /// For `CGImage` backed `UIImage`s, this function returns an equivalent `CIImage` backed `UIImage`, whether as,
    /// for already `CIImage` backed `UIImage`s, it returns `self`.
    func ciImageBackedCopy() -> UIImage? {
        guard ciImage == nil else { return self }
        guard let ciImage = CIImage(image: self) else { return nil }

        return UIImage(ciImage: ciImage)
    }
}
