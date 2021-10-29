//
//  Constants.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 11/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TUIKit

struct Constants {
    struct Size {}
    struct Spacing {}
    struct Color {}
    struct Margin {}
    struct Misc {}
    struct Animations {}
    struct ViewEffects {}
    struct Fonts {}
    struct Buttons {}
}

extension Constants {
    static var supportedInterfaceOrientations: UIInterfaceOrientationMask = {
        switch UIScreen.main.traitCollection.userInterfaceIdiom {
        case .pad:
            return .all
        default:
            return [.portrait, .portraitUpsideDown]
        }
    }()
}

extension Constants.Size {
    static let defaultToolbarHeight: CGFloat = 60
    static let mediumToolbarHeight: CGFloat = 70
    static let largeToolbarHeight: CGFloat = 82

    static let wideToolbarItem = CGSize(width: 83, height: 70)
    static let toolbarIcon = CGSize(width: 44, height: 44)
    static let maxImageInputSize = CGSize(width: 8192, height: 8192)

    static let toolbarButtonSize = CGSize(width: 24, height: 24)
    static let largeToolbarButtonSize = CGSize(width: 44, height: 44)
}

extension Constants.Spacing {
    static let toolbarItem: CGFloat = 6
    static let boundedRangeToolbarItem: CGFloat = 12
    static let commandToolbarInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    static let modulesToolbarInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    static let smallToolbarInsets = UIEdgeInsets(top: 8, left: 32, bottom: 8, right: 32)
    static let toolbarInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    static let insetContentLayout = NSDirectionalEdgeInsets(top: 40, leading: 40, bottom: 40, trailing: 40)
}

extension Constants.Color {
    static let background = UIColor.fromBundle("Background")
    static let secondaryBackground = UIColor.fromBundle("SecondaryBackground")
    static let tertiaryBackground = UIColor.fromBundle("TertiaryBackground")

    static let defaultTint = UIColor.fromBundle("DefaultTint")
    static let accent = UIColor.fromBundle("AccentColor")

    static let toolbarBackground = UIColor.fromBundle("ToolbarBackground")
    static let toolbarTint = UIColor.fromBundle("ToolbarTint")
    static let toolbarImageTint = UIColor.fromBundle("ToolbarImageTint")
}

extension Constants.Misc {
    static let cropHandleRadius: CGFloat = 9
    static let cropLineThickness: CGFloat = 3
    static let cropOutsideOpacity: Float = 0.75
}

extension Constants.Animations {
    static func `default`(duration: TimeInterval = 0.25, delay: TimeInterval = 0, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
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
    static let blur: UIBlurEffect = {
        if #available(iOS 13.0, *) {
            return UIBlurEffect(style: .systemChromeMaterial)
        } else {
            return UIBlurEffect(style: .regular)
        }
    }()
}

extension Constants.Fonts {
    static func `default`(ofSize size: CGFloat) -> UIFont {
        .init(name: "Montserrat-Regular", size: size) ?? .systemFont(ofSize: size)
    }

    static func semibold(ofSize size: CGFloat) -> UIFont {
        .init(name: "Montserrat-SemiBold", size: size) ?? .systemFont(ofSize: size)
    }

    static func bold(ofSize size: CGFloat) -> UIFont {
        .init(name: "Montserrat-Bold", size: size) ?? .systemFont(ofSize: size)
    }

    static let segmentedControlFont = `default`(ofSize: segmentedControlFontSize)

    static let standardToolbarButtonFontSize: CGFloat = UIFont.smallSystemFontSize
    static let navigationFontSize: CGFloat = 16
    static let segmentedControlFontSize: CGFloat = UIFont.smallSystemFontSize + 1
}

extension Constants.Buttons {
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
