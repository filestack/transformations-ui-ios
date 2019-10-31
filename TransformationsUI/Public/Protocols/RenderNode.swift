//
//  RenderNode.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol RenderNode: class {
    var uuid: UUID { get }

    var inputImage: CIImage { get set }
    var outputImage: CIImage { get }

    var delegate: RenderNodeDelegate? { get set }
    var pipeline: RenderPipeline? { get set }
}

public func ==(lhs: RenderNode, rhs: RenderNode) -> Bool {
    return lhs.uuid == rhs.uuid
}
