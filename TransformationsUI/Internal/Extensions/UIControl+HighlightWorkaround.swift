//
//  UIControl+HighlightWorkaround.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 11/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension UIControl {
    // Works around a bug where an Apple's `GestureRecognizer` at the bottom of the screen prevents any nearby controls
    // from highlighting when touched.
    //
    // Further discussion:
    // https://stackoverflow.com/questions/23046539/uibutton-fails-to-properly-register-touch-in-bottom-region-of-iphone-screen
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inside = super.point(inside: point, with: event)

        if inside != isHighlighted && event?.type == .touches {
            isHighlighted = inside
        }

        return inside
    }
}
