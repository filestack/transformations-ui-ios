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
        $0.innerInsets = Constants.Spacing.toolbarInsets
        $0.itemSpacing = Constants.Spacing.toolbarItem
        $0.itemStyle = .default
    }

    public static let discardApply = EditorToolbarStyle {
        $0.backgroundColor = Constants.Color.tertiaryBackground
        $0.innerInsets = Constants.Spacing.smallToolbarInsets
        $0.itemStyle = .default
    }

    public static let accented = EditorToolbarStyle {
        $0.innerInsets = Constants.Spacing.toolbarInsets
        $0.itemSpacing = Constants.Spacing.toolbarItem
        $0.itemStyle = .accented
    }

    public static let modules = EditorToolbarStyle {
        $0.fixedHeight = Constants.Size.mediumToolbarHeight
        $0.backgroundColor = Constants.Color.tertiaryBackground
        $0.innerInsets = Constants.Spacing.modulesToolbarInsets
        $0.itemSpacing = 0
        $0.itemStyle = .default
        $0.buttonConfig = Constants.CustomButtons.default()
    }

    public static let segments = EditorToolbarStyle {
        $0.fixedHeight = Constants.Size.defaultToolbarHeight
        $0.innerInsets = Constants.Spacing.commandToolbarInsets
        $0.itemSpacing = Constants.Spacing.toolbarItem
        $0.itemStyle = .textOnly
    }

    public static let twoRowSegments = EditorToolbarStyle {
        $0.fixedHeight = Constants.Size.largeToolbarHeight
        $0.innerInsets = Constants.Spacing.smallToolbarInsets
        $0.itemSpacing = Constants.Spacing.toolbarItem
        $0.itemStyle = .textOnly
    }

    public static let commands = EditorToolbarStyle {
        $0.fixedHeight = Constants.Size.defaultToolbarHeight
        $0.innerInsets = Constants.Spacing.commandToolbarInsets
        $0.buttonConfig = Constants.CustomButtons.default()
    }

    public static let togglingCommands = EditorToolbarStyle {
        $0.fixedHeight = Constants.Size.mediumToolbarHeight
        $0.innerInsets = Constants.Spacing.commandToolbarInsets
        $0.buttonConfig = Constants.CustomButtons.default(toggling: true)
    }

    public static let largeCommands = EditorToolbarStyle {
        $0.fixedHeight = Constants.Size.mediumToolbarHeight
        $0.innerInsets = Constants.Spacing.commandToolbarInsets
        $0.buttonConfig = Constants.CustomButtons.filters()
    }

    public static let boundedRangeCommand = EditorToolbarStyle {
        $0.itemSpacing = Constants.Spacing.boundedRangeToolbarItem
        $0.backgroundColor = Constants.Color.secondaryBackground
        $0.innerInsets = Constants.Spacing.toolbarInsets
        $0.itemStyle = .accented
        $0.axis = .vertical
    }
}

extension EditorToolbarItemStyle {
    public static let `default` = EditorToolbarItemStyle {
        $0.tintColor = Constants.Color.defaultTint
    }

    public static let accented = EditorToolbarItemStyle {
        $0.tintColor = Constants.Color.accent
    }

    public static let textOnly: EditorToolbarItemStyle = {
        var style = `default`

        style.mode = .text

        return style
    }()
}
