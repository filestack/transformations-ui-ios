//
//  Modules.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 13/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

/// Represents a collection of premium modules available for processing images with
/// [Transformations UI](https://www.filestack.com/docs/concepts/transform_ui/).
public class Modules: EditorModules {
    /// Returns an array of all the supported modules.
    public lazy var all: [EditorModule] = [transform, filters, adjustments, text, stickers, overlays, border]

    /// Transform module.
    public let transform = Transform()

    /// Filters module.
    public let filters = Filters()

    /// Adjustments module.
    public let adjustments = Adjustments()

    /// Text module.
    public let text = Text()

    /// Sticker module.
    public let stickers = Stickers()

    /// Overlays module.
    public let overlays = Overlays()

    /// Border module.
    public let border = Border()

    /// Designated initializer for `Modules`.
    ///
    /// - Parameter apiKey: A Filestack API key that has permission to use
    /// [Transformations UI](https://www.filestack.com/docs/concepts/transform_ui/).
    public init() {}
}
