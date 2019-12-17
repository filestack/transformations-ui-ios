//
//  CIImageViewDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 17/12/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol CIImageViewDelegate: class {
    func imageChanged(image: CIImage?)
}
