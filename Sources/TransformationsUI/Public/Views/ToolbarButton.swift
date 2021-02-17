//
//  ToolbarButton.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 25/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

public class ToolbarButton: UIButton {
    public var imageCornerRadius: CGFloat = 0 {
        didSet {
            imageView?.layer.cornerRadius = imageCornerRadius
            imageView?.layer.masksToBounds = imageCornerRadius > 0
        }
    }
}
