//
//  Modules+Transform.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 15/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol ExtraModuleCommand: EditorModuleCommand {}
public protocol CropModuleCommand: EditorModuleCommand {}

extension Modules {
    /// Transform module configuration object.
    public class Transform: NSObject, EditorModule {
        /// :nodoc:
        public let uuid = UUID()
        /// :nodoc:
        public var title: String = "Transform"
        /// :nodoc:
        public var icon: UIImage? = .fromBundle("icon-module-transform")
        /// :nodoc:
        public var isEnabled: Bool = true
        /// :nodoc:
        public let controllerType: EditorModuleController.Type = TransformController.self
        /// :nodoc:
        public let nodeCategory: RenderNodeCategory = .image
        /// :nodoc:
        public var nodeType: RenderGroupChildNode.Type? = TransformRenderNode.self
        /// :nodoc:
        public var autocreatesNode: Bool = true

        /// Extra Commands available in `Transform` module.
        public var extraCommands: [ExtraModuleCommand] = [
            Commands.Resize(),
            Commands.Flip(),
            Commands.Flop(),
            Commands.Rotate(clockWise: false),
            Commands.Rotate(clockWise: true)
        ]

        /// Crop Commands available in `Transform` module.
        public var cropCommands: [CropModuleCommand] = [
            Commands.Crop(type: .none),
            Commands.Crop(type: .rect),
            Commands.Crop(type: .circle)
        ]
    }
}

extension Modules.Transform {
    /// All available commands.
    public class Commands {
        /// Resize command.
        public class Resize: PointerHashable, ExtraModuleCommand {
            /// :nodoc:
            public let uuid = UUID()
            /// :nodoc:
            private(set) public lazy var title = "Resize"
            /// :nodoc:
            private(set) public lazy var icon: UIImage? = .fromBundle("icon-resize")
        }

        /// Flip command.
        public class Flip: PointerHashable, ExtraModuleCommand {
            /// :nodoc:
            public let uuid = UUID()
            /// :nodoc:
            private(set) public lazy var title = "Flip"
            /// :nodoc:
            private(set) public lazy var icon: UIImage? = .fromBundle("icon-flip")
        }

        /// Flop command.
        public class Flop: PointerHashable, ExtraModuleCommand {
            /// :nodoc:
            public let uuid = UUID()
            /// :nodoc:
            private(set) public lazy var title = "Flop"
            /// :nodoc:
            private(set) public lazy var icon: UIImage? = .fromBundle("icon-flop")
        }

        /// Rotate command.
        public class Rotate: PointerHashable, ExtraModuleCommand {
            /// :nodoc:
            public let uuid = UUID()
            /// :nodoc:
            private(set) public lazy var title = "Rotate"
            /// :nodoc:
            private(set) public lazy var icon: UIImage? = .fromBundle(clockWise ? "icon-rotate-right" : "icon-rotate-left")

            /// Whether rotation direction should be clockwise.
            public let clockWise: Bool

            /// Designated `Rotate` command initializer.
            ///
            /// - Parameter clockWise: Whether rotation direction should be clockwise. Defaults to `false`.
            public init(clockWise: Bool = false) {
                self.clockWise = clockWise
            }
        }

        /// Crop command.
        public class Crop: PointerHashable, CropModuleCommand {
            /// :nodoc:
            public let uuid = UUID()
            /// :nodoc:
            private(set) public lazy var title: String = {
                switch type {
                case .none:
                    return "None"
                case .rect:
                    switch aspectRatio {
                    case .original:
                        return "Original"
                    case let .custom(ratio):
                        return "\(Int(ratio.width)):\(Int(ratio.height))"
                    case .free:
                        return "Rect"
                    }
                case .circle:
                    return "Circle"
                }
            }()

            /// :nodoc:
            private(set) public lazy var icon: UIImage? = {
                switch type {
                case .none:
                    return nil
                case .rect:
                    switch aspectRatio {
                    case .free: return .fromBundle("icon-crop")
                    case .original: return .fromBundle("icon-crop-constrained")
                    case .custom(_): return .fromBundle("icon-crop-custom")
                    }
                case .circle:
                    return .fromBundle("icon-circle")
                }
            }()

            /// Crop type.
            @frozen public enum CropType {
                /// No crop.
                case none
                /// Rectangular crop.
                case rect
                /// Circular crop.
                case circle
            }

            /// Aspect ratio.
            @frozen public enum AspectRatio {
                /// Aspect ratio should not be kept.
                case free
                /// Maintains the original image's aspect ratio.
                case original
                /// Uses a custom aspect ratio (e.g.: 16:9.)
                case custom(_ ratio: CGSize)
            }

            /// Determines the `CropType` to use.
            let type: CropType

            /// Determines the `AspectRatio` to use.
            let aspectRatio: AspectRatio

            /// Designated initializer for `Crop` command.
            ///
            /// - Parameters:
            ///   - type: A `CropType`. Defaults to `rect`
            ///   - aspectRatio: An `AspectRatio`. Defaults to `free`.
            ///   - title: A title representing this crop type. Overrides the default title *(optional)*.
            ///   - icon: An icon representing this crop type. Overrides the default icon *(optional)*.
            public init(type: CropType = .rect, aspectRatio: AspectRatio = .free, title: String? = nil, icon: UIImage? = nil) {
                self.type = type
                self.aspectRatio = aspectRatio

                if let title = title {
                    self.title = title
                }

                if let icon = icon {
                    self.icon = icon
                }
            }
        }
    }
}
