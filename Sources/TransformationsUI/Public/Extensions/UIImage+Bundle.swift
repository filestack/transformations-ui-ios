//
//  UIImage+Bundle.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 27/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

public extension UIImage {
    static func fromBundle(_ name: String) -> UIImage {
        return UIImage(named: name, in: bundle, compatibleWith: nil) ?? UIImage()
    }
}
