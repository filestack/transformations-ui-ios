//
//  RenderNodeTransform.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 26/11/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

enum RenderNodeTransform: RenderNodeChange {
    public enum CropType {
        case rect
        case circle
    }

    case rotate
    case crop(insets: UIEdgeInsets, type: RenderNodeTransform.CropType)
}
