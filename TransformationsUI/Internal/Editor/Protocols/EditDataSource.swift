//
//  EditDataSource.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

protocol EditDataSource: AnyObject {
    var imageFrame: CGRect { get }
    var imageSize: CGSize { get }
    var imageOrigin: CGPoint { get }
    var imageActualSize: CGSize { get }
}
