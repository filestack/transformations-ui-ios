//
//  RenderNode.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

/// Represents a render node that may be used in a `RenderPipeline`.
open class RenderNode: PointerHashable {
    public let uuid: UUID

    public required init(uuid: UUID? = nil) {
        self.uuid = uuid ?? UUID()
    }
}

/// An object describing a render node change.
public protocol RenderNodeChange: Any {}

/// The protocol any `RenderNode` delegates must conform to.
public protocol RenderNodeDelegate: AnyObject {
    /// Called when a node changed.
    ///
    /// Use it to perform an action when node changes frequently (e.g. a slider is modifying the brightness of this node.)
    ///
    /// Typically, this implementation will be concerned about updating the next render node's input image in the pipeline.
    func nodeChanged(node: RenderNode)

    /// Called when a node finished changing, optionally my contain a `RenderNodeChange` object describing the change.
    ///
    /// Use it to perform an action (e.g. registering an undo step) after the node finishes changing.
    func nodeFinishedChanging(node: RenderNode, change: RenderNodeChange?)
}

/// A specific kind of `RenderNode` that can contain other nodes and conforms to `RenderNodeDelegate`.
public protocol RenderGroupNode: RenderNode & RenderNodeDelegate {
    var delegate: RenderNodeDelegate? { get set }

    func add(node: RenderGroupChildNode)
    func remove(node: RenderGroupChildNode)
    func node(with uuid: UUID) -> RenderGroupChildNode?

    func canMoveBack(node: RenderGroupChildNode) -> Bool
    func canMoveForward(node: RenderGroupChildNode) -> Bool

    func moveBack(node: RenderGroupChildNode)
    func moveForward(node: RenderGroupChildNode)
}

/// A specific kind of `RenderNode` that belongs to a `RenderGroupNode`.
public protocol RenderGroupChildNode: RenderNode {
    var group: RenderGroupNode? { get set }
}

/// A specific kind of `RenderNode` that contains an input and output `CIImage`.
public protocol IONode: RenderNode {
    var inputImage: CIImage { get set }
    var outputImage: CIImage { get }
}

/// A specific kind of `RenderNode` that contains a `UIView`.
public protocol ViewableNode: RenderNode {
    var view: UIView { get }
}

/// A specific kind of `RenderNode` that can apply changes that originated in another node.
public protocol ChangeApplyingNode: RenderNode {
    func apply(change: RenderNodeChange?, from node: RenderNode)
}

/// A specific kind of `RenderGroupChildNode` that can be transformed.
public protocol ObjectRenderNode: RenderGroupChildNode & ViewableNode {
    var center: CGPoint { get set }
    var bounds: CGRect { get set }
    var transform: CGAffineTransform { get set }
    var opacity: CGFloat { get set }
}
