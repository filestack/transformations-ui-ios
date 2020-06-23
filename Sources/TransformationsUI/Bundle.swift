//
//  TransformationsUI.swift
//  
//
//  Created by Ruben Nine on 23/06/2020.
//

import Foundation

private class BundleFinder {}

/// Returns the bundle that is associated to this module (supports SPM.)
let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleFinder.self)
    #endif
}()
