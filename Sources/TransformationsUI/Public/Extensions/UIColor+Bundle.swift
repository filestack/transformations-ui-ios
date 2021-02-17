//
//  UIColor+Bundle.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 27/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

public extension UIColor {
    static func fromBundle(_ name: String) -> UIColor {
        return UIColor(named: name, in: bundle, compatibleWith: nil) ?? UIColor()
    }
}
