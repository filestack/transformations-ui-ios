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
        didSet { pipeline?.nodeChanged(node: self) }
    }

    var outputImage: CIImage { inputImage }
}
