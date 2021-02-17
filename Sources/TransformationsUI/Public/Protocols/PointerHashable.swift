//
//  PointerHashable.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 7/12/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

public protocol PointerHashable: class, Hashable {}

extension PointerHashable {
    public static func == (left: Self, right: Self) -> Bool { left === right }
    public func hash(into hasher: inout Hasher) { ObjectIdentifier(self).hash(into: &hasher) }
}
