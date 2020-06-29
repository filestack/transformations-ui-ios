//
//  TransformViewController+ToolbarDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

extension TransformViewController: StandardToolbarDelegate {
    func toolbarItemSelected(toolbar: StandardToolbar, item: DescriptibleEditorItem, control: UIControl) {
        let command = item as? EditorModuleCommand

        switch command {
        case is Module.Commands.Rotate:
            perform(command: .rotate(clockwise: false))
        case let crop as Module.Commands.Crop:
            editMode = crop.type == .none ? .none : .crop(mode: crop)
        default:
            break
        }
    }
}

extension TransformViewController {
    private enum NodeCommand {
        case rotate(clockwise: Bool)
        case cropRect(insets: UIEdgeInsets)
        case cropCircle(center: CGPoint, radius: CGFloat)
    }

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

    func applyPendingChanges() {
        switch editMode {
        case .crop(let mode):
            switch mode.type {
            case .none:
                break
            case .rect:
                perform(command: .cropRect(insets: cropHandler.actualEdgeInsets))
            case .circle:
                perform(command: .cropCircle(center: circleHandler.actualCenter, radius: circleHandler.actualRadius))
            }
        case .none:
            break
        }
    }
}
