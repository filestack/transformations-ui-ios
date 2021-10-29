//
//  WeakContainer.swift
//  TUIKit
//
//  Created by Ruben Nine on 22/10/21.
//

import Foundation

class WeakContainer<T>: Equatable, Hashable where T: AnyObject & Hashable {
    private weak var object : T?

    init (object: T) {
        self.object = object
    }

    func get() -> T? {
        object
    }

    func hash(into hasher: inout Hasher) {
        guard let object = object else { return }

        return hasher.combine(object.hashValue)
    }

    static func == (lhs: WeakContainer<T>, rhs: WeakContainer<T>) -> Bool {
        return lhs.object === rhs.object
    }
}
