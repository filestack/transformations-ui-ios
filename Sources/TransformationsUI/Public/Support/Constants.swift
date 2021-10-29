//
//  Constants.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 11/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TUIKit

public struct Constants {
    public struct Size {}
    public struct Spacing {}
    public struct Color {}
    public struct Margin {}
    public struct Misc {}
    public struct Animations {}
    public struct ViewEffects {}
    public struct Fonts {}
    public struct CustomButtons {}
}

extension Constants.Size {
    public static let defaultToolbarHeight: CGFloat = 60
    public static let mediumToolbarHeight: CGFloat = 70
    public static let largeToolbarHeight: CGFloat = 82

    public static let wideToolbarItem = CGSize(width: 83, height: 70)
    public static let toolbarIcon = CGSize(width: 44, height: 44)
    public static let maxImageInputSize = CGSize(width: 8192, height: 8192)

    public static let toolbarButtonSize = CGSize(width: 24, height: 24)
    public static let largeToolbarButtonSize = CGSize(width: 44, height: 44)
}

extension Constants.Spacing {
    public static let toolbarItem: CGFloat = 6
    public static let boundedRangeToolbarItem: CGFloat = 12
    public static let commandToolbarInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    public static let modulesToolbarInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    public static let smallToolbarInsets = UIEdgeInsets(top: 8, left: 32, bottom: 8, right: 32)
    public static let toolbarInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    public static let insetContentLayout = NSDirectionalEdgeInsets(top: 40, leading: 40, bottom: 40, trailing: 40)
}

extension Constants.Color {
    public static let background = UIColor.fromBundle("Background")
    public static let secondaryBackground = UIColor.fromBundle("SecondaryBackground")
    public static let tertiaryBackground = UIColor.fromBundle("TertiaryBackground")

    public static let defaultTint = UIColor.fromBundle("DefaultTint")
    public static let accent = UIColor.fromBundle("AccentColor")

    public static let toolbarBackground = UIColor.fromBundle("ToolbarBackground")
    public static let toolbarTint = UIColor.fromBundle("ToolbarTint")
    public static let toolbarImageTint = UIColor.fromBundle("ToolbarImageTint")
}

extension Constants.Misc {
    public static let cropHandleRadius: CGFloat = 9
    public static let cropLineThickness: CGFloat = 3
    public static let cropOutsideOpacity: Float = 0.75
}

extension Constants.Animations {
    public static func `default`(duration: TimeInterval = 0.25, delay: TimeInterval = 0, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration,
            delay: delay,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.9,
            options: [.curveEaseInOut],
            animations: animations,
            completion: completion
        )
    }
}

extension Constants.ViewEffects {
    public static let blur: UIBlurEffect = {
        if #available(iOS 13.0, *) {
            return UIBlurEffect(style: .systemChromeMaterial)
        } else {
            return UIBlurEffect(style: .regular)
        }
    }()
}

extension Constants.Fonts {
    public static func `default`(ofSize size: CGFloat) -> UIFont {
        .init(name: "Montserrat-Regular", size: size) ?? .systemFont(ofSize: size)
    }

    public static func semibold(ofSize size: CGFloat) -> UIFont {
        .init(name: "Montserrat-SemiBold", size: size) ?? .systemFont(ofSize: size)
    }

    public static func bold(ofSize size: CGFloat) -> UIFont {
        .init(name: "Montserrat-Bold", size: size) ?? .systemFont(ofSize: size)
    }

    public static let segmentedControlFont = `default`(ofSize: segmentedControlFontSize)

    public static let standardToolbarButtonFontSize: CGFloat = UIFont.smallSystemFontSize
    public static let navigationFontSize: CGFloat = 16
    public static let segmentedControlFontSize: CGFloat = UIFont.smallSystemFontSize + 1
}

extension Constants.CustomButtons {
    static func `default`(toggling: Bool = false) -> TUIButton.UIConfig {
        var states: [UIButton.State: TUIButton.UIConfig.StateConfig] = [
            .normal: .init(tintColor: Constants.Color.toolbarTint,
                           imageTintColor: Constants.Color.toolbarImageTint)
        ]

        if toggling {
            states[.selected] = .init(backgroundColor: Constants.Color.toolbarBackground)
        }
        
        return .init(
            spacing: 3,
            insets: UIEdgeInsets(top: 3, left: 6, bottom: 3, right: 6),
            cornerMode: .round(radius: 5),
            font: Constants.Fonts.default(ofSize: Constants.Fonts.standardToolbarButtonFontSize),
            imageSize: Constants.Size.toolbarButtonSize,
            states: states
        )
    }

    static func filters() -> TUIButton.UIConfig {
        .init(
            spacing: 3,
            insets: UIEdgeInsets(top: 3, left: 6, bottom: 3, right: 6),
            cornerMode: .roundImage(radius: 5),
            font: Constants.Fonts.default(ofSize: Constants.Fonts.standardToolbarButtonFontSize),
            imageSize: Constants.Size.largeToolbarButtonSize,
            states: [
                .selected: .init(alpha: 1.0),
                .normal: .init(tintColor: Constants.Color.toolbarTint, alpha: 0.2)
            ]
        )
    }
}
