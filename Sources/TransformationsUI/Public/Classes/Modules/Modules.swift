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
    // MARK: - Public Properties

    /// Returns an array of all the supported modules.
    public lazy var all: [EditorModule] = [transform, filters, adjustments, border, text, stickers, overlays]

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
    public init() {
        /* NO-OP */
    }
}
