//
//  ObjectToolbarItem.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 26/11/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

enum ObjectToolbarItemType {
    case edit
    case delete
    case resetTransform
    case sendBack
    case sendForward
}

class ObjectToolbarItem: NSObject, DescriptibleEditorItem {
    let uuid = UUID()
    let title: String
    let icon: UIImage?
    let type: ObjectToolbarItemType

    init(title: String, icon: UIImage, type: ObjectToolbarItemType) {
        self.title = title
        self.icon = icon
        self.type = type
    }
}
