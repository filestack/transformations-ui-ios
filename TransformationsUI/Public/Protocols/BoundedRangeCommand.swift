//
//  BoundedRangeCommand.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 28/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

public protocol BoundedRangeCommand {
    var defaultValue: Double { get }
    var range: Range<Double> { get }
    var componentLabels: [String] { get }
}
