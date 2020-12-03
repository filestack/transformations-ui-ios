//
//  TransformViewController+ToolbarDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

extension TransformController: StandardToolbarDelegate {
    func toolbarItemSelected(toolbar: StandardToolbar, item: DescriptibleEditorItem, control: UIControl) {
        let command = item as? EditorModuleCommand

        switch command {
        case is Module.Commands.Rotate:
            perform(transform: .rotate)
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
        rectCropHandler.reset()
        circleCropHandler.reset()
    }

    func applyPendingChanges() {
        switch editMode {
        case .crop(let mode):
            switch mode.type {
            case .none:
                break
            case .rect:
                perform(transform: .crop(insets: rectCropHandler.actualEdgeInsets, type: .rect))
            case .circle:
                perform(transform: .crop(insets: circleCropHandler.actualEdgeInsets, type: .circle))
            }
        case .none:
            break
        }
    }
}
