//
//  RenderPipeline.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import MetalKit

protocol RenderPipelineDelegate: AnyObject {
    /// Called whenever the pipeline's content changed in a meaningful way.
    func pipelineChanged(pipeline: RenderPipeline)
}

/// `RenderPipeline` is responsible for maintaining a hierarchy of rendering nodes that can be rendered or presented
/// visually inside an `UIView`.
class RenderPipeline {
    // MARK: - Internal Properties

    weak var delegate: RenderPipelineDelegate?

    let view: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    var outputImage: UIImage {
        UIImage(ciImage: imageRenderNodeGroup.outputImage)
            .merge(with: objectRenderNodeGroup.view.renderToImage())
            .merge(with: overlayRenderNodeGroup.view.renderToImage())
    }

    /// Image render node group (contains the original image with all the transformations and filters applied.)
    let imageRenderNodeGroup = ImageRenderNodeGroup()

    /// Object render node group (contains object nodes such as text, stickers, etc.)
    let objectRenderNodeGroup = LayeredRenderNodeGroup()

    /// Overlay render node group (contains nodes that should be rendered on top of everything else such as borders, etc.)
    let overlayRenderNodeGroup = LayeredRenderNodeGroup()

    // MARK: - Private Properties

    private var nodes: [RenderGroupNode] = []

    // MARK: - Lifecycle

    init?(inputImage: UIImage) {
        guard let metalDevice = MTLCreateSystemDefaultDevice() else { return nil }
        guard let cgImage = inputImage.cgImage else { return nil }

        let textureLoader = MTKTextureLoader(device: metalDevice)

        let loaderOptions: [MTKTextureLoader.Option : Any] = [
            MTKTextureLoader.Option.SRGB : false,
            MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.flippedVertically
        ]

        let colorSpace = cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()

        guard let sourceTexture = try? textureLoader.newTexture(cgImage: cgImage, options: loaderOptions) else { return nil }
        guard let ciImage = CIImage(mtlTexture: sourceTexture)?.matchedToWorkingSpace(from: colorSpace) else { return nil }

        imageRenderNodeGroup.metalDevice = metalDevice
        imageRenderNodeGroup.inputImage = ciImage

        add(node: imageRenderNodeGroup)
        add(node: objectRenderNodeGroup)
        add(node: overlayRenderNodeGroup)
    }

    deinit {
        cleanup()
    }
}

// MARK: - Private Functions

private extension RenderPipeline {
    func add(node: RenderGroupNode) {
        node.delegate = self

        // Add node to `nodes` array.
        nodes.append(node)

        // Add node view to `view` in case it has one.
        if let nodeView = (node as? ViewableNode)?.view {
            view.addSubview(nodeView)
        }
    }

    func remove(node: RenderGroupNode) {
        (node as? ViewableNode)?.view.removeFromSuperview()

        nodes.removeAll { $0 === node }
    }

    func cleanup() {
        imageRenderNodeGroup.removeAllNodes()
        objectRenderNodeGroup.removeAllNodes()
        overlayRenderNodeGroup.removeAllNodes()

        for node in nodes {
            remove(node: node)
        }
    }
}

extension RenderPipeline: RenderNodeDelegate {
    func nodeChanged(node: RenderNode) {
        switch node {
        case let ioNode as IONode:
            let extent = ioNode.outputImage.extent

            // Update pipeline's view `frame` and `transform` if dimensions changed.
            if view.bounds.size != extent.size {
                view.transform = .identity
                view.frame = CGRect(origin: .zero, size: extent.size)
            }

            // Update any other viewable nodes' view frames.
            let otherViewableNodes = (nodes.filter { $0 !== ioNode }).compactMap { $0 as? ViewableNode }

            for node in otherViewableNodes {
                node.view.frame = CGRect(origin: .zero, size: extent.size)
            }
        default:
            /*  NO-OP */
            break
        }
    }

    func nodeFinishedChanging(node: RenderNode, change: RenderNodeChange?) {
        if let change = change {
            // Apply change to any other nodes that support it.
            let changedNode = node
            let changeApplyingNodes = (nodes.filter { $0 != node }).compactMap { ($0 as? ChangeApplyingNode) }

            for node in changeApplyingNodes {
                node.apply(change: change, from: changedNode)
            }
        }

        delegate?.pipelineChanged(pipeline: self)
    }
}

// MARK: - Snapshotable Implementation

extension RenderPipeline: Snapshotable {
    // Takes a snapshot of every node in the render pipeline.
    func snapshot() -> Snapshot {
        var snapshot = Snapshot()

        for node in nodes {
            guard let nodeSnapshot = (node as? Snapshotable)?.snapshot() else { continue }
            snapshot[node.uuid.uuidString] = nodeSnapshot
        }

        return snapshot
    }

    // Restores a snapshot of every node in the render pipeline.
    func restore(from snapshot: Snapshot) {
        for node in nodes {
            guard let nodeSnapshot = snapshot[node.uuid.uuidString] as? Snapshot else { continue }
            (node as? Snapshotable)?.restore(from: nodeSnapshot)
        }
    }
}
