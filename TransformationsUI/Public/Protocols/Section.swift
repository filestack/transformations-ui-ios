//
//  Section.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol Section: UIViewController {
    var title: String? { get }
    var icon: UIImage { get }

    var renderNode: RenderNode { get }
}
