//
//  EditorToolbarDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 30/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

protocol EditorToolbarDelegate: AnyObject {
    func cancelSelected()
    func doneSelected()

    func undoSelected()
    func redoSelected()
}
