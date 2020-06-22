//
//  StandardModules+Transform.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 15/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol ExtraModuleCommand: EditorModuleCommand {}
public protocol CropModuleCommand: EditorModuleCommand {}

extension StandardModules {
    public class Transform: NSObject, EditorModule {
        public var title: String = "Transform"
        public var icon: UIImage? = .fromFrameworkBundle("icon-module-transform")
        public var isEnabled: Bool = true

        public lazy var viewController: EditorModuleVC = {
            return TransformViewController(module: self)
        }()

        /// Extra Commands available in `Transform` module.
        public var extraCommands: [ExtraModuleCommand] = [
            Commands.Rotate(),
        ]

        /// Crop Commands available in `Transform` module.
        public var cropCommands: [CropModuleCommand] = [
            Commands.Crop(type: .none),
            Commands.Crop(type: .rect),
            Commands.Crop(type: .circle)
        ]
    }
}

// MARK: - Commands

extension StandardModules.Transform {
    /// All available commands.
    public class Commands: NSObject {
        /// Rotate command.
        public class Rotate: NSObject, ExtraModuleCommand {
            public var title: String = "Rotate"
            public lazy var icon: UIImage? = UIImage.fromFrameworkBundle("icon-rotate")
        }

        /// Crop command.
        public class Crop: NSObject, CropModuleCommand {
            public lazy var title: String = {
                switch type {
                case .none:
                    return "None"
                case .rect:
                    return "Freefrom"
                case .circle:
                    return "Circle"
                }
            }()

            public lazy var icon: UIImage? = {
                switch type {
                case .none:
                    return nil
                case .rect:
                    return .fromFrameworkBundle("icon-crop")
                case .circle:
                    return .fromFrameworkBundle("icon-circle")
                }
            }()

            /// Crop type.
            public enum CropType {
                case none
                case rect
                case circle
            }

            let type: CropType

            public init(type: CropType = .rect) {
                self.type = type
            }
        }
    }
}
