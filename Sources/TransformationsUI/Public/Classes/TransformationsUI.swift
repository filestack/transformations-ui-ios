//
//  TransformationsUI.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 22/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

/// The delegate for `TransformationsUI`.
public protocol TransformationsUIDelegate: AnyObject {
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
        super.init()
        self.setup()
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

private extension TransformationsUI {
    func setup() {
        // Register custom fonts.
        for font in Config.fontsURLs() {
            do {
                try UIFont.register(from: font)
            } catch {
                print("Error registering font:", error.localizedDescription)
            }
        }

        let font: UIFont = Constants.Fonts.semibold(ofSize: Constants.Fonts.navigationFontSize)

        // Setup custom font and foreground colors.
        // Navigation bar.
        UINavigationBar.appearance().titleTextAttributes = [
            .font: font,
            .foregroundColor: Constants.Color.defaultTint
        ]

        // Bar button item.
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                .font: font,
                .foregroundColor: Constants.Color.accent
            ],
            for: UIControl.State.normal
        )
    }
}
