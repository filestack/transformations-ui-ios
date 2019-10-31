//
//  TransformationsUIDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol TransformationsUIDelegate: class {

    /// Called when the editor is dismissed.
    ///
    /// - Parameter image: Returns the resulting edited `UIImage`, if available.
    func editorDismissed(with image: UIImage?)
}
