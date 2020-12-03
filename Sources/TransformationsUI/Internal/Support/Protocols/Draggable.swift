//
//  Draggable.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 27/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

protocol Draggable: UIView {
    var handleType: HandleType { get }
}
