//
//  TransformRenderNode.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

class TransformRenderNode: RenderNode, RenderGroupChildNode & IONode {
    weak var group: RenderGroupNode?

    var inputImage: CIImage = CIImage() {
        didSet { renderedImage = inputImage }
    }

    var outputImage: CIImage { renderedImage ?? inputImage }

    var renderedImage: CIImage? = nil {
        didSet { group?.nodeChanged(node: self) }
    }
}

extension TransformRenderNode {
    func apply(transform: RenderNodeTransform) {
        renderedImage = outputImage.transformed(using: transform)
        group?.nodeFinishedChanging(node: self, change: transform)
    }
}

extension TransformRenderNode: Snapshotable {
    /// :nodoc:
    public func snapshot() -> Snapshot {
        return ["renderedImage": renderedImage]
    }

    /// :nodoc:
    public func restore(from snapshot: Snapshot) {
        for item in snapshot {
            switch item {
            case let("renderedImage", image as CIImage):
                renderedImage = image
            default:
                break
            }
        }
    }
}
