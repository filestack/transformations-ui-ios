//
//  LayeredRenderNodeGroup.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 21/11/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

class LayeredRenderNodeGroup: RenderNode, RenderGroupNode & ViewableNode {
    typealias Node = RenderGroupChildNode & ViewableNode

    let view: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true

        return view
    }()

    weak var delegate: RenderNodeDelegate?
    weak var parent: RenderGroupNode?

    private var nodes: [RenderGroupChildNode] = []
}

// MARK: - Public Functions

extension LayeredRenderNodeGroup {
    func add(node: RenderGroupChildNode) {
        guard let node = node as? Node else { return }

        node.group = self
        nodes.append(node)
        view.addSubview(node.view)
    }

    func remove(node: RenderGroupChildNode) {
        guard let node = node as? Node else { return }

        node.view.removeFromSuperview()
        node.group = nil

        nodes.removeAll { $0 === node }
    }

    func canMoveBack(node: RenderGroupChildNode) -> Bool {
        return nodes.first?.uuid != node.uuid
    }

    func canMoveForward(node: RenderGroupChildNode) -> Bool {
        return nodes.last?.uuid != node.uuid
    }

    func moveBack(node: RenderGroupChildNode) {
        guard canMoveBack(node: node) else { return }
        guard let idx = (nodes.firstIndex { $0.uuid == node.uuid }) else { return }

        nodes.swapAt(idx, nodes.index(before: idx))

        guard let nodeView = (node as? ViewableNode)?.view, nodeView.superview == view else { return }
        guard let viewIdx = (view.subviews.firstIndex { $0 == nodeView }) else { return }

        view.exchangeSubview(at: viewIdx, withSubviewAt: view.subviews.index(before: viewIdx))
    }

    func moveForward(node: RenderGroupChildNode) {
        guard canMoveForward(node: node) else { return }
        guard let idx = (nodes.firstIndex { $0.uuid == node.uuid }) else { return }

        nodes.swapAt(idx, nodes.index(after: idx))

        guard let nodeView = (node as? ViewableNode)?.view, nodeView.superview == view else { return }
        guard let viewIdx = (view.subviews.firstIndex { $0 == nodeView }) else { return }

        view.exchangeSubview(at: viewIdx, withSubviewAt: view.subviews.index(after: viewIdx))
    }

    func node(with uuid: UUID) -> RenderGroupChildNode? {
        return nodes.first { $0.uuid == uuid }
    }

    func node(at location: CGPoint) -> RenderGroupChildNode? {
        guard let hitView = view.hitTest(location, with: nil) else { return nil }

        return nodes.first { ($0 as? ViewableNode)?.view == hitView }
    }
}

extension LayeredRenderNodeGroup: ChangeApplyingNode {
    func apply(change: RenderNodeChange?, from node: RenderNode) {
        let changedNode = node

        for node in nodes {
            (node as? ChangeApplyingNode)?.apply(change: change, from: changedNode)
        }
    }
}

// MARK: - RenderNodeDelegate Conformance

extension LayeredRenderNodeGroup: RenderNodeDelegate {
    func nodeChanged(node: RenderNode) {
        // NO-OP
    }

    func nodeFinishedChanging(node: RenderNode, change: RenderNodeChange?) {
        delegate?.nodeFinishedChanging(node: self, change: change)
    }
}

// MARK: - Snapshotable Implementation

extension LayeredRenderNodeGroup: Snapshotable {
    // Takes a snapshot of every node in the group.
    func snapshot() -> Snapshot {
        let payload: [[String: Any]] = nodes.compactMap {
            guard let snapshot = ($0 as? Snapshotable)?.snapshot() else { return nil }

            return [
                "uuid": $0.uuid,
                "type": type(of: $0),
                "snapshot": snapshot
            ]
        }

        return ["payload": payload]
    }

    // Restores a snapshot of every node in the group.
    func restore(from snapshot: Snapshot) {
        var oldNodes = nodes

        guard let payload = snapshot["payload"] as? [[String: Any]] else { return }

        for (position, data) in payload.enumerated() {
            guard let uuid = data["uuid"] as? UUID else { return }
            guard let type = data["type"] as? RenderGroupChildNode.Type else { return }
            guard let snapshot = data["snapshot"] as? Snapshot else { return }

            let node: RenderGroupChildNode

            if let existingNode = (nodes.first { $0.uuid == uuid }) {
                // Use existing node.
                node = existingNode
            } else {
                // Create new node with a given `uuid`.
                node = type.init(uuid: uuid)
                // Add new node to hierarchy.
                add(node: node)
            }

            // Fix child node position if needed.
            if let currentPosition = (nodes.firstIndex { $0 === node }), currentPosition != position {
                nodes.swapAt(currentPosition, position)
            }

            if let viewableNode = (node as? ViewableNode) {
                // Fix child node view order if needed.
                if let currentPosition = view.subviews.firstIndex(of: viewableNode.view), currentPosition != position {
                    view.exchangeSubview(at: currentPosition, withSubviewAt: position)
                }
            }

            (node as? Snapshotable)?.restore(from: snapshot)

            oldNodes.removeAll { $0 === node }
        }

        // Remove any nodes that are not contained on the snapshot.
        for node in oldNodes {
            remove(node: node)
        }
    }
}
