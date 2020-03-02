//
//  EditorModule.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol EditorModuleVC: UIViewController {
    var imageView: CIImageView { get }

    func getRenderNode() -> RenderNode
    func editorRestoredSnapshot()
}

extension EditorModuleVC {
    public func buildImageView() -> CIImageView {
        return MetalImageView()
    }

    public func updateImageView() {
        imageView.image = getRenderNode().pipeline?.outputImage
    }

    public func editorRestoredSnapshot() {
        // NO-OP
    }
}
