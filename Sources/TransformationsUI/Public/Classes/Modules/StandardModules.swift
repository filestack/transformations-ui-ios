//
//  StandardModules.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 14/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

public class StandardModules: EditorModules {
    public lazy var all: [EditorModule] = [transform]
    public var transform = Transform()
    public init() {}
}
