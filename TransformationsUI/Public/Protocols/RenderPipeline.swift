//
//  RenderPipeline.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol RenderPipeline: class {
    /// The `RenderPipeline` delegate.
    var delegate: RenderPipelineDelegate? { get set }

    /// An input `CIImage`.
    var inputImage: CIImage { get }

    /// An output `CIImage`.
    var outputImage: CIImage { get }

    /// Adds a node to the pipeline.
    /// - Parameter node: The `RenderNode` to add.
    func addNode(node: RenderNode)

    /// Removes a node from the pipeline.
    /// - Parameter node: The `RenderNode` to remove.
    func removeNode(node: RenderNode)

    /// Called when a node changed.
    /// Use it to perform an action when node changes frequently (e.g. a slider is modifying the brightness of this node.)
    /// Typically, this implementation will be concerned about updating the next render node's input image in the pipeline.
    func nodeChanged(node: RenderNode)

    /// Called when a node finished changing.
    /// Use it to perform an action (e.g. registering an undo step) after the node finishes changing.
    func nodeFinishedChanging(node: RenderNode)
}
