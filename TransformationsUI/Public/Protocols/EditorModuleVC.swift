//
//  EditorModule.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol EditorModuleVC: UIViewController {
    var renderNode: RenderNode { get }
    var imageView: CIImageView { get }
}

extension EditorModuleVC {
    public func buildImageView() -> CIImageView {
        return MetalImageView()
    }
}
