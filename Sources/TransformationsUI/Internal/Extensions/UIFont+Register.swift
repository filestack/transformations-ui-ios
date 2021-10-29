//
//  File.swift
//  
//
//  Created by Ruben Nine on 18/10/21.
//

import UIKit

enum TUIError: Error {
    case unableToCreateFontDataProvider
}

extension UIFont {
    static func register(from url: URL) throws {
        guard let fontDataProvider = CGDataProvider(url: url as CFURL) else {
            throw TUIError.unableToCreateFontDataProvider
        }

        var error: Unmanaged<CFError>?

        guard let font = CGFont(fontDataProvider), CTFontManagerRegisterGraphicsFont(font, &error) else {
            throw error!.takeUnretainedValue()
        }
    }
}
