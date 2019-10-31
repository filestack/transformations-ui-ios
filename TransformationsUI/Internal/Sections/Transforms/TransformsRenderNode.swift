//
//  TransformsRenderNode.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

class TransformsRenderNode: RenderNode {
    weak var pipeline: RenderPipeline?
    weak var delegate: RenderNodeDelegate?

    let uuid = UUID()

    var inputImage: CIImage = CIImage() {
        didSet { renderedImage = inputImage }
    }

    var outputImage: CIImage {
        return renderedImage ?? inputImage
    }

    var renderedImage: CIImage? = nil {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.renderNodeOutputChanged(renderNode: self)
            }
        }
    }

    func rotate(clockwise: Bool) {
        renderedImage = outputImage.rotated(clockwise: clockwise)
    }

    func crop(insets: UIEdgeInsets) {
        renderedImage = outputImage.cropped(by: insets)
    }

    func circled(center: CGPoint, radius: CGFloat) {
        renderedImage = outputImage.circled(center: center, radius: radius)
    }
}

extension TransformsRenderNode: Snapshotable {
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
