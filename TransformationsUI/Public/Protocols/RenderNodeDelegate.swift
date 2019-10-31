//
//  RenderNodeDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

public protocol RenderNodeDelegate: class {
    /// Called when the `renderNode`'s output changes.
    func renderNodeOutputChanged(renderNode: RenderNode)
}
