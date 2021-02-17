//
//  BorderRenderNode.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 10/08/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

class BorderRenderNode: RenderNode, RenderGroupChildNode & ViewableNode {
    weak var group: RenderGroupNode? {
        didSet { updateSize() }
    }

    let view: UIView = UIView()

    var width: CGFloat = 0.0 {
        didSet { updateBorder() }
    }

    var opacity: CGFloat = 1.0 {
        didSet { updateBorder() }
    }

    var color: UIColor = .white {
        didSet { updateBorder() }
    }
}

extension BorderRenderNode: ChangeApplyingNode {
    func apply(change: RenderNodeChange?, from node: RenderNode) {
        updateSize()
        updateBorder()
    }
}

// MARK: - Private Functions

private extension BorderRenderNode {
    func updateSize() {
        if let size = (group as? ViewableNode)?.view.frame.size {
            view.frame.size = size
        }
    }

    func updateBorder() {
        view.layer.borderWidth = CGFloat(width * min(view.frame.width, view.frame.height))
        view.layer.borderColor = color.withAlphaComponent(CGFloat(opacity)).cgColor
    }
}

extension BorderRenderNode: Snapshotable {
    public func snapshot() -> Snapshot {
        return [
            "borderWidth": width,
            "opacity": opacity,
            "color": color,
        ]
    }

    public func restore(from snapshot: Snapshot) {
        updateSize()

        for item in snapshot {
            switch item {
            case let("borderWidth", borderWidth as CGFloat):
                self.width = borderWidth
            case let("opacity", opacity as CGFloat):
                self.opacity = opacity
            case let("color", color as UIColor):
                self.color = color
            default:
                break
            }
        }
    }
}
