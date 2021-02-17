//
//  L18.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 11/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

public struct L18 {
    public static let save = l18("Save")
    public static let cancel = l18("Cancel")
}

private extension L18 {
    static let UIKitBundle = Bundle(identifier: "com.apple.UIKit")

    static func l18(_ string: String) -> String {
        return UIKitBundle?.localizedString(forKey: string, value: nil, table: nil) ?? string
    }
}
