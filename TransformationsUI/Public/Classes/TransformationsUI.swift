//
//  TransformationsUI.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 22/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

@objc(FSTransformationsUI) public class TransformationsUI: NSObject {
    // MARK: - Public Properties

    public weak var delegate: TransformationsUIDelegate?

    public let config: Config

    // MARK: - Lifecycle Functions

    public init(with config: Config) {
        self.config = config
    }

    // MARK: - Public Functions

    open func editor(with image: UIImage, using modules: [EditorModule.Type] = Config.defaultModules) -> UIViewController? {
        let instantiatedModules = modules.map { $0.init(config: config) }

        return EditorViewController(image: image, config: config, modules: instantiatedModules) { image in
            self.delegate?.editorDismissed(with: image)
        }
    }
}
