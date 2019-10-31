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

    public func editor(with image: UIImage) -> UIViewController? {
        let sections = config.availableSections.map { $0.init() }

        return EditorViewController(image: image, sections: sections) { image in
            self.delegate?.editorDismissed(with: image)
        }
    }
}
