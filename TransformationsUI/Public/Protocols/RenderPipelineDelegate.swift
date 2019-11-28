//
//  RenderPipelineDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

public protocol RenderPipelineDelegate: class {
    func outputChanged(pipeline: RenderPipeline)
    func outputFinishedChanging(pipeline: RenderPipeline)
}
