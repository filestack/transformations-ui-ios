//
//  Constants.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 11/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public struct Constants {
    public struct Size {}
    public struct Spacing {}
    public struct Color {}
    public struct Margin {}
    public struct Misc {}
    public struct Animations {}
    public struct ViewEffects {}
}

extension Constants.Size {
    public static let defaultToolbarHeight: CGFloat = 60
    public static let mediumToolbarHeight: CGFloat = 70
    public static let largeToolbarHeight: CGFloat = 82
    public static let segmentToolbarHeight: CGFloat = 82

    public static let toolbarItem = CGSize(width: 60, height: 60)
    public static let wideToolbarItem = CGSize(width: 80, height: 60)
    public static let toolbarIcon = CGSize(width: 44, height: 44)
    public static let maxImageInputSize = CGSize(width: 8192, height: 8192)
}

extension Constants.Spacing {
    public static let toolbarItem: CGFloat = 6
    public static let toolbarInset: CGFloat = toolbarItem * 2
    public static let insetContentLayout = NSDirectionalEdgeInsets(top: 40, leading: 40, bottom: 40, trailing: 40)
}

extension Constants.Color {
    public static let background = UIColor.fromBundle("Background")
    public static let moduleBackground = UIColor.fromBundle("ModuleBackground")
    public static let innerToolbar = UIColor.fromBundle("InnerToolbar")
    public static let defaultTint = UIColor.fromBundle("DefaultTint")
    public static let primaryActionTint = UIColor.fromBundle("PrimaryActionTint")
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
