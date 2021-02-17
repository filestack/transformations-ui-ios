//
//  Styles.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 25/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

extension EditorToolbarStyle {
    public static let `default` = EditorToolbarStyle {
        $0.fixedHeight = Constants.Size.defaultToolbarHeight
        $0.innerInset = Constants.Spacing.toolbarInset
        $0.itemSpacing = Constants.Spacing.toolbarItem
        $0.itemStyle = .default
    }

    public static let modules = EditorToolbarStyle {
        $0.fixedHeight = Constants.Size.mediumToolbarHeight
        $0.backgroundColor = Constants.Color.background
        $0.itemSpacing = Constants.Spacing.toolbarItem
        $0.itemStyle = .default
    }

    public static let segments = EditorToolbarStyle {
        $0.fixedHeight = Constants.Size.defaultToolbarHeight
        $0.innerInset = Constants.Spacing.toolbarInset
        $0.itemSpacing = Constants.Spacing.toolbarItem
        $0.itemStyle = .textOnly
    }

    public static let twoRowSegments = EditorToolbarStyle {
        $0.fixedHeight = Constants.Size.largeToolbarHeight
        $0.innerInset = Constants.Spacing.toolbarItem
        $0.itemSpacing = Constants.Spacing.toolbarItem
        $0.itemStyle = .textOnly
    }

    public static let commands = EditorToolbarStyle {
        $0.fixedHeight = Constants.Size.defaultToolbarHeight
        $0.itemStyle = .round
    }

    public static let largeCommands = EditorToolbarStyle {
        $0.fixedHeight = Constants.Size.largeToolbarHeight
        $0.itemStyle = .round
    }

    public static let boundedRangeCommand = EditorToolbarStyle {
        $0.innerInset = Constants.Spacing.toolbarInset
        $0.itemSpacing = Constants.Spacing.toolbarItem * 2
        $0.itemStyle = .default
        $0.axis = .vertical
    }
}

extension EditorToolbarItemStyle {
    public static let `default` = EditorToolbarItemStyle {
        $0.tintColor = Constants.Color.defaultTint
    }

    public static let textOnly = EditorToolbarItemStyle {
        $0.tintColor = Constants.Color.defaultTint
        $0.mode = .text
    }

    public static let round = EditorToolbarItemStyle {
        $0.tintColor = Constants.Color.defaultTint
        $0.cornerRadius = 4
    }
}
