//
//  TransformRenderNode.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

class TransformRenderNode: RenderNode {
    weak var pipeline: RenderPipeline?

    let uuid = UUID()

    var inputImage: CIImage = CIImage() {
        didSet { renderedImage = inputImage }
    }

    var outputImage: CIImage {
        return renderedImage ?? inputImage
    }

    var renderedImage: CIImage? = nil {
        didSet { pipeline?.nodeChanged(node: self) }
    }

    func discardChanges() {
        renderedImage = nil
    }
}

extension TransformRenderNode {
    func rotate(clockwise: Bool) {
        renderedImage = outputImage.rotated(clockwise: clockwise)
    }

    func cropRect(insets: UIEdgeInsets) {
        renderedImage = outputImage.cropped(by: insets)
    }

    func cropCircle(center: CGPoint, radius: CGFloat) {
        renderedImage = outputImage.circled(center: center, radius: radius)
    }
}

extension TransformRenderNode: Snapshotable {
    public func snapshot() -> Snapshot {
        return [
            "renderedImage": renderedImage
        ]
    }

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
