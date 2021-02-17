//
//  RGBComponent.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 2/26/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

enum RGBComponent: Int {
    case red
    case green
    case blue
}

extension RGBComponent: CustomStringConvertible {
    var description: String {
        switch self {
        case .red: return "Red"
        case .green: return "Green"
        case .blue: return "Blue"
        }
    }
}
