//
//  Constants.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 11/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public struct Constants {
    private init() {}

    public struct Size {
        private init() {}
    }

    public struct Spacing {
        private init() {}
    }

    public struct Color {
        private init() {}
    }

    public struct Margin {
        private init() {}
    }

    public struct Misc {
        private init() {}
    }
}

extension Constants.Size {
    public static let toolbar: CGSize = CGSize(width: 60, height: 60)
    public static let toolbarIcon: CGSize = CGSize(width: 36, height: 36)
}

extension Constants.Spacing {
    public static let toolbar: CGFloat = 6
    public static let toolbarInset: CGFloat = toolbar * 2
    public static let contentLayout = UIEdgeInsets(top: 5, left: 40, bottom: 5, right: 40)
}

extension Constants.Color {
    public static let toolbar = UIColor.black.withAlphaComponent(0.1)
    public static let background = UIColor(white: 31 / 255, alpha: 1)
    public static let canvasBackground = UIColor.white.withAlphaComponent(0.05)
    public static let icon = UIColor.white
    public static let label = UIColor.white
    public static let cancel = UIColor.white
    public static let done = UIColor(red: 240 / 255, green: 180 / 255, blue: 0, alpha: 1)
}

extension Constants.Misc {
    public static let cropHandleRadius: CGFloat = 9
    public static let cropLineThickness: CGFloat = 3
    public static let cropOutsideOpacity: Float = 0.7
}
