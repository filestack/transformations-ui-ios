//
//  StandardModules.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 14/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

/// Represents a collection of standard modules available for processing images with
/// [Transformations UI](https://www.filestack.com/docs/concepts/transform_ui/).
public class StandardModules: EditorModules {
    /// Returns an array of all the supported modules.
    public lazy var all: [EditorModule] = [transform]

    /// Transform module.
    public var transform = Transform()

    /// Designated initializer for `StandardModules`.
    public init() {}
}
