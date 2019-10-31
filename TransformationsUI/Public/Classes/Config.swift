//
//  Config.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

@objc(FSConfig) public class Config: NSObject {
    private static let defaultSections = [TransformsViewController.self]

    /// Represents the list of sections available in the editor.
    public var availableSections: [Section.Type] = defaultSections
}
