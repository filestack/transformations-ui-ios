//
//  TransformsViewController+ToolbarDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension TransformsViewController: ModuleToolbarDelegate {
    private enum NodeCommand {
        case rotate(clockwise: Bool)
        case cropRect(insets: UIEdgeInsets)
        case cropCircle(center: CGPoint, radius: CGFloat)
    }

    func toolbarItemSelected(sender: UIButton) {
        let command = config.commands[sender.tag]

        switch command {
        case is Config.Commands.Rotate:
            perform(command: .rotate(clockwise: false))
        case let crop as Config.Commands.Crop:
            editMode = editMode == .crop(mode: crop) ? .none : .crop(mode: crop)
        default:
            break
        }
    }

    func saveSelected() {
        switch editMode {
        case .crop(let mode):
            switch mode.type {
            case .rect:
                perform(command: .cropRect(insets: cropHandler.actualEdgeInsets))
            case .circle:
                perform(command: .cropCircle(center: circleHandler.actualCenter, radius: circleHandler.actualRadius))
            }
        case .none:
            return
        }

        editMode = .none
    }

    // MARK: - Private Functions

    private func perform(command: NodeCommand) {
        switch command {
        case let .rotate(clockwise):
            renderNode.rotate(clockwise: clockwise)
        case let .cropRect(insets):
            renderNode.cropRect(insets: insets)
        case let .cropCircle(center, radius):
            renderNode.cropCircle(center: center, radius: radius)
        }

        editMode = .none
        cropHandler.reset()
        circleHandler.reset()

        renderNode.pipeline?.nodeFinishedChanging(node: renderNode)
    }
}
