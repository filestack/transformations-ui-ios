//
//  Snapshotable.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

public typealias Snapshot = [String: Any?]

public protocol Snapshotable {
    func snapshot() -> Snapshot
    func restore(from snapshot: Snapshot)
}
