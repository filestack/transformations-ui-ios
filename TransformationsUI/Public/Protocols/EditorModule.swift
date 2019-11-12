//
//  EditorModule.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol EditorModule: UIViewController {
    var title: String? { get }
    var icon: UIImage { get }

    var renderNode: RenderNode { get }
    var imageView: CIImageView { get }
}

extension EditorModule {
    public func buildImageView() -> CIImageView {
        return MetalImageView()
    }
}
