//
//  UIImage+Merge.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 10/12/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

extension UIImage {
    func merge(with image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)

        let rect = CGRect(origin: .zero, size: size)
        draw(in: rect)

        image.draw(in: rect, blendMode: .normal, alpha: 1.0)

        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return mergedImage
    }
}

