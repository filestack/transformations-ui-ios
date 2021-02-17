//
//  FontStyle.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 2/28/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

/// Represents a font style composed by one or more options.
public struct FontStyle: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// No style.
    public static let none = FontStyle([])

    /// Bold style.
    public static let bold = FontStyle(rawValue: 1 << 0)

    /// Italic style.
    public static let italic = FontStyle(rawValue: 1 << 1)

    /// Underline style.
    public static let underline  = FontStyle(rawValue: 1 << 2)
}
