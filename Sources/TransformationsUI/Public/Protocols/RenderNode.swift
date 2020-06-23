//
//  RenderNode.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol RenderNode: class {
    var pipeline: RenderPipeline? { get set }
    var uuid: UUID { get }
    var inputImage: CIImage { get set }
    var outputImage: CIImage { get }
}

public func ==(lhs: RenderNode, rhs: RenderNode) -> Bool {
    return lhs.uuid == rhs.uuid
}
