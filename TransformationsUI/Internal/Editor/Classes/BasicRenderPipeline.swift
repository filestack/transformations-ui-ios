//
//  BasicRenderPipeline.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

class BasicRenderPipeline: RenderPipeline {
    // MARK: - Internal Properties

    weak var delegate: RenderPipelineDelegate?

    let inputImage: CIImage

    var outputImage: CIImage {
        // Use last node's output image, if available, or return input image otherwise.
        return nodes.last?.value.outputImage ?? inputImage
    }

    // MARK: - Private Properties

    private var nodes = LinkedList<RenderNode>()
    private var shouldNotifyFinishedChanging = false

    // MARK: - Lifecycle Functions

    init(inputImage: CIImage) {
        self.inputImage = inputImage
    }

    // MARK: - Internal Functions

    func addNode(node: RenderNode) {
        // Set node's input image to previous node's output image or, if there's no previous node, use pipeline's input image.
        node.inputImage = nodes.last?.value.outputImage ?? inputImage
        node.pipeline = self

        // Add node to linked list
        nodes.append(value: node)
    }

    func removeNode(node: RenderNode) {
        guard let innerNode = innerNode(for: node) else { return }

        // Reconnect next node's input image to previous node's output image, or, if there's no previous node,
        // use pipeline's input image.
        innerNode.next?.value.inputImage = innerNode.previous?.value.outputImage ?? inputImage

        // Remove node from linked list
        _ = nodes.remove(node: innerNode)
    }

    func nodeChanged(node: RenderNode) {
        updateNextNode(using: node)
    }

    func nodeFinishedChanging(node: RenderNode) {
        shouldNotifyFinishedChanging = true
        updateNextNode(using: node)
    }

    // MARK: - Private Functions

    @discardableResult private func updateNextNode(using node: RenderNode) -> Bool {
        let nextNode = innerNode(for: node)?.next?.value

        // Update next node's input image.
        nextNode?.inputImage = node.outputImage

        DispatchQueue.main.async {
            self.delegate?.outputChanged(pipeline: self)

            if nextNode == nil, self.shouldNotifyFinishedChanging {
                self.shouldNotifyFinishedChanging = false
                self.delegate?.outputFinishedChanging(pipeline: self)
            }
        }

        return true
    }

    private func innerNode(for node: RenderNode) -> Node<RenderNode>? {
        var someNode = nodes.first

        while someNode != nil {
            if someNode!.value == node {
                return someNode!
            }

            someNode = someNode!.next
        }

        return nil
    }
}

// MARK: - Snapshotable Implementation

extension BasicRenderPipeline: Snapshotable {
    // Takes a snapshot of every node in the render pipeline.
    public func snapshot() -> Snapshot {
        var snapshots = Snapshot()
        var node: Node<RenderNode>? = nodes.first

        while node != nil {
            if let snapshot = (node!.value as? Snapshotable)?.snapshot() {
                snapshots[node!.value.uuid.uuidString] = snapshot
            }

            node = node!.next
        }

        return snapshots
    }

    // Restores a snapshot of every node in the render pipeline.
    public func restore(from snapshot: Snapshot) {
        var node: Node<RenderNode>? = nodes.first

        while node != nil {
            if let renderNode = node?.value, let nodeSnapshot = snapshot[renderNode.uuid.uuidString] as? Snapshot {
                (renderNode as? Snapshotable)?.restore(from: nodeSnapshot)
            }

            node = node!.next
        }
    }
}
