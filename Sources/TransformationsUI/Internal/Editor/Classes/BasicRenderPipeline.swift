//
//  BasicRenderPipeline.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

class BasicRenderPipeline: RenderPipeline {
    // MARK: - Internal Properties

    weak var delegate: RenderPipelineDelegate?

    let inputImage: CIImage

    var outputImage: CIImage {
        // Use last node's output image, if available, or return input image otherwise.
        return linkedNodes.last?.value.outputImage ?? inputImage
    }

    // MARK: - Private Properties

    private var linkedNodes = LinkedList<RenderNode>()
    private var shouldNotifyFinishedChanging = false
    private var nodeToLinkNodeMap = NSMapTable<AnyObject, LinkedList<RenderNode>.Node>(keyOptions: .weakMemory,
                                                                                       valueOptions: .weakMemory)

    // MARK: - Lifecycle

    init(inputImage: CIImage) {
        self.inputImage = inputImage
    }
}

// MARK: - Internal Functions

extension BasicRenderPipeline {
    func addNode(node: RenderNode) {
        node.pipeline = self

        // Set node's `inputImage` to previous node's `outputImage`, or fallback to `inputImage`.
        node.inputImage = linkedNodes.last?.value.outputImage ?? inputImage

        // Add node to linked list
        let linkedNode = linkedNodes.append(value: node)

        // Add map from node to linkNode
        nodeToLinkNodeMap.setObject(linkedNode, forKey: node)
    }

    func removeNode(node: RenderNode) {
        guard let linkedNode = linkedNode(for: node) else { return }

        // Reconnect next node's `inputImage` to previous node's `outputImage`, or fallback to `inputImage`.
        linkedNode.next?.value.inputImage = linkedNode.previous?.value.outputImage ?? inputImage

        // Remove node from linked list
        linkedNodes.remove(node: linkedNode)

        // Remove map from node to linkNode
        nodeToLinkNodeMap.removeObject(forKey: node)
    }

    func nodeChanged(node: RenderNode) {
        updateNode(after: node)
    }

    func nodeFinishedChanging(node: RenderNode) {
        shouldNotifyFinishedChanging = true
        updateNode(after: node)
    }
}

// MARK: - Private Functions

extension BasicRenderPipeline {
    private func updateNode(after node: RenderNode) {
        let nextNode = linkedNode(for: node)?.next?.value

        // Update next node's input image.
        nextNode?.inputImage = node.outputImage

        delegate?.outputChanged(pipeline: self)

        if nextNode == nil, shouldNotifyFinishedChanging {
            shouldNotifyFinishedChanging = false
            delegate?.outputFinishedChanging(pipeline: self)
        }
    }

    private func linkedNode(for node: RenderNode) -> LinkedList<RenderNode>.Node? {
        return nodeToLinkNodeMap.object(forKey: node)
    }
}

// MARK: - Snapshotable Implementation

extension BasicRenderPipeline: Snapshotable {
    // Takes a snapshot of every node in the render pipeline.
    func snapshot() -> Snapshot {
        var snapshot = Snapshot()

        for node in linkedNodes {
            guard let nodeSnapshot = (node.value as? Snapshotable)?.snapshot() else { continue }

            snapshot[node.value.uuid.uuidString] = nodeSnapshot
        }

        return snapshot
    }

    // Restores a snapshot of every node in the render pipeline.
    func restore(from snapshot: Snapshot) {
        for node in linkedNodes {
            guard let nodeSnapshot = snapshot[node.value.uuid.uuidString] as? Snapshot else { continue }

            (node.value as? Snapshotable)?.restore(from: nodeSnapshot)
        }
    }
}
