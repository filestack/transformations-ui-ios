//
//  StandardModules.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 14/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public class StandardModules: NSObject, EditorModules {
    public lazy var all: [EditorModule] = [transforms]

    public var transforms = Transforms()
}
