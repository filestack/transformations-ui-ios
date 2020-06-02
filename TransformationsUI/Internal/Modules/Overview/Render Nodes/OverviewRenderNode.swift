//
//  OverviewRenderNode.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

class OverviewRenderNode: RenderNode {
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
