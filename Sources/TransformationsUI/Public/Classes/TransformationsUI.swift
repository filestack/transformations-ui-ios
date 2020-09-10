//
//  TransformationsUI.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 22/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

/// The delegate for `TransformationsUI`.
public protocol TransformationsUIDelegate: class {
    /// Called when the editor is dismissed.
    ///
    /// - Parameter image: Returns the resulting edited `UIImage`, if available.
    func editorDismissed(with image: UIImage?)
}

/// The `TransformationsUI` class provides the means to configure and instantiate the
/// Transformations UI view controller set up for editing a given image.
public class TransformationsUI: NSObject {
    // MARK: - Public Properties

    /// The `TransformationsUI` delegate. Optional.
    public weak var delegate: TransformationsUIDelegate?

    /// A `Config` object that configures `TransformationsUI`.
    public let config: Config

    // MARK: - Lifecycle

    /// Designated initializer.
    ///
    /// - Parameter config: A `Config` object.
    public init(with config: Config) {
        self.config = config
    }

    // MARK: - Open Functions

    /// Returns a view controller with the Transformations UI editor set up for editing a given
    /// image.
    ///
    /// - Parameter image: The `UIImage` to edit.
    open func editor(with image: UIImage) -> UIViewController? {
        return EditorViewController(image: image, config: config) { image in
            self.delegate?.editorDismissed(with: image)
        }
    }
}
