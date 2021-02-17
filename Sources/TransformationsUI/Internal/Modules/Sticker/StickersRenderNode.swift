//
//  StickersRenderNode.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 14/12/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

class StickersRenderNode: RenderNode, RenderGroupChildNode & ObjectRenderNode & ViewableNode {
    weak var group: RenderGroupNode?

    var center: CGPoint = .zero {
        didSet { updatedCenter() }
    }

    var bounds: CGRect = .zero {
        didSet { updatedBounds() }
    }

    var transform: CGAffineTransform = .identity {
        didSet { updatedTransform() }
    }

    var image: UIImage? {
        didSet { updatedImage() }
    }

    var opacity: CGFloat = 1 {
        didSet { updatedOpacity() }
    }

    var section: String?

    private(set) lazy var view: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
}

extension StickersRenderNode: ChangeApplyingNode {
    func apply(change: RenderNodeChange?, from node: RenderNode) {
        if let transform = change as? RenderNodeTransform {
            apply(transform: transform)
        }
    }
}

// MARK: - Private Functions

private extension StickersRenderNode {
    func updatedCenter() {
        view.center = center
    }

    func updatedBounds() {
        view.bounds = bounds
    }

    func updatedTransform() {
        view.transform = transform
    }

    func updatedImage() {
        view.layer.contentsScale = image?.scale ?? 1.0
        view.layer.contents = image?.cgImage
    }

    func updatedOpacity() {
        view.alpha = opacity
    }
}

// MARK: - Snapshotable Protocol Implementation

extension StickersRenderNode: Snapshotable {
    public func snapshot() -> Snapshot {
        return [
            "center": center,
            "bounds": bounds,
            "transform": transform,
            "opacity": opacity,
            "image": image,
            "section": section
        ]
    }

    func restore(from snapshot: Snapshot) {
        if let center = snapshot["center"] as? CGPoint {
            self.center = center
        }

        if let bounds = snapshot["bounds"] as? CGRect {
            self.bounds = bounds
        }

        if let transform = snapshot["transform"] as? CGAffineTransform {
            self.transform = transform
        }

        if let opacity = snapshot["opacity"] as? CGFloat {
            self.opacity = opacity
        }

        if let image = snapshot["image"] as? UIImage {
            self.image = image
        }

        if let section = snapshot["section"] as? String {
            self.section = section
        }
    }
}
