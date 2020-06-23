//
//  EditorModuleVCDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

public protocol EditorModuleVCDelegate: class {
    func moduleWantsToDiscardChanges(module: EditorModule)
    func moduleWantsToApplyChanges(module: EditorModule)
}
