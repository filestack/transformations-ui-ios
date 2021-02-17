//
//  TransformController+ToolbarDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension TransformController: StandardToolbarDelegate {
    func toolbarItemSelected(toolbar: StandardToolbar, item: DescriptibleEditorItem, control: UIControl) {
        let command = item as? EditorModuleCommand

        switch command {
        case is Module.Commands.Flip:
            perform(transform: .flip)
        case is Module.Commands.Flop:
            perform(transform: .flop)
        case let rotate as Module.Commands.Rotate:
            perform(transform: .rotate(clockwise: rotate.clockWise))
        case let crop as Module.Commands.Crop:
            editMode = crop.type == .none ? .none : .crop(mode: crop)
        default:
            break
        }
    }
}

extension TransformController {
    private func perform(transform: RenderNodeTransform) {
        renderNode.apply(transform: transform)

        editMode = .none
        cropHandler.reset()
        circleHandler.reset()
    }

    func applyPendingChanges() {
        switch editMode {
        case .crop(let mode):
            switch mode.type {
            case .none:
                break
            case .rect:
                perform(transform: .crop(insets: cropHandler.actualEdgeInsets, type: .rect))
            case .circle:
                perform(transform: .crop(insets: circleHandler.actualEdgeInsets, type: .circle))
            }
        case .none:
            break
        }
    }
}

// MARK: - ResizeViewController Delegate

extension TransformController: ResizeViewControllerDelegate {
    func resizeViewControllerDismissed(with size: CGSize) {
        let ratio = CGSize(width: size.width / renderNode.outputImage.extent.width,
                           height: size.height / renderNode.outputImage.extent.height)

        perform(transform: .resize(ratio: ratio))
    }
}
