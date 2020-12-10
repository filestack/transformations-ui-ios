//
//  ImageRenderNodeGroup.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 21/11/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared
import MetalKit

class ImageRenderNodeGroup: RenderNode, RenderGroupNode & IONode & ViewableNode {
    typealias Node = RenderGroupChildNode & IONode

    weak var delegate: RenderNodeDelegate?
    weak var parent: RenderGroupNode?

    var view: UIView { imageView }
    var metalDevice: MTLDevice? = nil

    var inputImage: CIImage = CIImage() {
        didSet { linkedNodes.first?.value.inputImage = inputImage }
    }

    var outputImage: CIImage { linkedNodes.last?.value.outputImage ?? inputImage }

    private lazy var imageView: CIImageView = {
        let view = CIImageView(frame: .zero, device: metalDevice)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true

        return view
    }()

    private var shouldNotifyDelegate: Bool = false
    private var notifiableChange: RenderNodeChange? = nil
    private var linkedNodes = LinkedList<Node>()
    private var nodeToLinkNodeMap = NSMapTable<AnyObject, LinkedList<Node>.Node>(keyOptions: .weakMemory,
                                                                                 valueOptions: .weakMemory)
}

// MARK: - Public Functions

extension ImageRenderNodeGroup {
    func add(node: RenderGroupChildNode) {
        guard let node = node as? Node else { return }

        node.group = self

        // Add node to linked list
        let linkedNode = linkedNodes.append(value: node)

        node.inputImage = linkedNode.previous?.value.outputImage ?? inputImage

        // Add map from node to linkNode
        nodeToLinkNodeMap.setObject(linkedNode, forKey: node)
    }

    func remove(node: RenderGroupChildNode) {
        guard let node = node as? Node else { return }

        node.group = nil

        guard let linkedNode = linkedNode(for: node) else { return }

        // Reconnect next node's `inputImage` to previous node's `outputImage`, or fallback to `inputImage`.
        linkedNode.next?.value.inputImage = linkedNode.previous?.value.outputImage ?? inputImage

        // Remove node from linked list
        linkedNodes.remove(node: linkedNode)

        // Remove map from node to linkNode
        nodeToLinkNodeMap.removeObject(forKey: node)
    }

    func removeAllNodes() {
        for linkedNode in linkedNodes {
            remove(node: linkedNode.value)
        }
    }

    func canMoveBack(node: RenderGroupChildNode) -> Bool { return false }
    func canMoveForward(node: RenderGroupChildNode) -> Bool { return false }
    func moveBack(node: RenderGroupChildNode) { return }
    func moveForward(node: RenderGroupChildNode) { return }

    func node(with uuid: UUID) -> RenderGroupChildNode? {
        return linkedNodes.map(\.value).first { $0.uuid == uuid }
    }
}

extension ImageRenderNodeGroup: RenderNodeDelegate {
    func nodeChanged(node: RenderNode) {
        guard let node = node as? Node else { return }
        updateNode(after: node)
    }

    func nodeFinishedChanging(node: RenderNode, change: RenderNodeChange?) {
        notifiableChange = change
        shouldNotifyDelegate = true
        nodeChanged(node: node)
    }
}

// MARK: - Private Functions

private extension ImageRenderNodeGroup {
    func updateNode(after node: Node) {
        if let nextNode = linkedNode(for: node)?.next?.value {
            // Update next node's input image.
            nextNode.inputImage = node.outputImage
        } else {
            // Update image view
            imageView.image = outputImage

            if let delegate = delegate {
                delegate.nodeChanged(node: self)

                if shouldNotifyDelegate {
                    // Notify pipeline changed
                    shouldNotifyDelegate = false
                    delegate.nodeFinishedChanging(node: self, change: notifiableChange)
                    notifiableChange = nil
                }
            }
        }
    }

    func linkedNode(for node: Node) -> LinkedList<Node>.Node? {
        return nodeToLinkNodeMap.object(forKey: node)
    }
}

// MARK: - Snapshotable Implementation

extension ImageRenderNodeGroup: Snapshotable {
    // Takes a snapshot of every node in the group.
    func snapshot() -> Snapshot {
        var snapshot = Snapshot()

        for linkedNode in linkedNodes {
            guard let nodeSnapshot = (linkedNode.value as? Snapshotable)?.snapshot() else { continue }

            snapshot[linkedNode.value.uuid.uuidString] = nodeSnapshot
        }

        return snapshot
    }

    // Restores a snapshot of every node in the group.
    func restore(from snapshot: Snapshot) {
        for linkedNode in linkedNodes {
            guard let nodeSnapshot = snapshot[linkedNode.value.uuid.uuidString] as? Snapshot else { continue }

            (linkedNode.value as? Snapshotable)?.restore(from: nodeSnapshot)
        }
    }
}
