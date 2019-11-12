//
//  Config.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

@objc(FSConfig) public class Config: NSObject {
    public static let defaultModules: [EditorModule.Type] = [TransformsViewController.self]
}
