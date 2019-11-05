//
//  UIImage+Bundle.swift
//  TransformationsUI
//
//  Created by Mihály Papp on 30/07/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import UIKit

extension UIImage {
    static func fromFrameworkBundle(_ name: String) -> UIImage {
        return UIImage(named: name, in: Bundle(for: TransformationsUI.self), compatibleWith: nil) ?? UIImage()
    }
}
