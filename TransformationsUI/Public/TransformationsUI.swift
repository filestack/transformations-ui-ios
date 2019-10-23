//
//  TransformationsUI.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 22/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

@objc(FSTransformationsUI) public class TransformationsUI: NSObject {

    public func editor(with image: UIImage, completion: @escaping (UIImage?) -> Void) -> UIViewController {
        return EditorViewController(image: image, completion: completion)
    }
}
