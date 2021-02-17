//
//  RenderNodeTransform.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 26/11/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

public enum RenderNodeTransform: RenderNodeChange {
    public enum CropType {
        case rect
        case circle
    }

    case flip
    case flop
    case rotate(clockwise: Bool)
    case resize(ratio: CGSize)
    case crop(insets: UIEdgeInsets, type: RenderNodeTransform.CropType)
}
