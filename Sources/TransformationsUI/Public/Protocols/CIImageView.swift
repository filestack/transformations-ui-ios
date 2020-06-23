//
//  CIImageView.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 11/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol CIImageView: UIView {
    var image: CIImage? { set get }
}
