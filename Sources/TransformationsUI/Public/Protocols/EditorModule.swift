//
//  EditorModule.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 14/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

public protocol EditorModule: DescriptibleEditorItem {
    var isEnabled: Bool { get }
    var controllerType: EditorModuleController.Type { get }
    var nodeType: RenderGroupChildNode.Type? { get }
    var nodeCategory: RenderNodeCategory { get }
    var autocreatesNode: Bool { get }
}
