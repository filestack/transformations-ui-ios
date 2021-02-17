//
//  BoundedRangeCommand.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 28/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

public enum BoundedRangeFormat {
    case numeric
    case percent
    case degrees
}

public protocol BoundedRangeCommand: EditorModuleCommand {
    var defaultValue: Double { get }
    var range: Range<Double> { get }
    var componentLabels: [String] { get }
    var format: BoundedRangeFormat { get }

    func formattedString(using value: Double) -> String
}

extension BoundedRangeCommand {
    public func formattedString(using value: Double) -> String {
        switch format {
        case .numeric:
            let numberFormatter = NumberFormatter()

            numberFormatter.maximumFractionDigits = 1
            numberFormatter.multiplier = 1
            numberFormatter.numberStyle = .decimal

            return numberFormatter.string(from: NSNumber(floatLiteral: value))!
        case .percent:
            let percentage = value / range.upperBound
            let numberFormatter = NumberFormatter()

            numberFormatter.maximumFractionDigits = 0
            numberFormatter.multiplier = 100
            numberFormatter.numberStyle = .percent

            return numberFormatter.string(from: NSNumber(floatLiteral: percentage))!
        case .degrees:
            let degrees = value * (180 / Double.pi)

            let numberFormatter = NumberFormatter()

            numberFormatter.maximumFractionDigits = 0
            numberFormatter.multiplier = 1
            numberFormatter.percentSymbol = "°"
            numberFormatter.numberStyle = .percent

            return numberFormatter.string(from: NSNumber(floatLiteral: degrees))!
        }
    }
}
