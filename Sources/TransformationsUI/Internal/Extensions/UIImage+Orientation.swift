//
//  UIImage+Orientation.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 3/11/21.
//  Copyright © 2021 Filestack. All rights reserved.
//

import UIKit

extension UIImage {
    var normalizedImage: UIImage? {
        guard imageOrientation != .up else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: size))

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
