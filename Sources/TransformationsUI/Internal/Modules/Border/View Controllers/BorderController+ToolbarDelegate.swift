//
//  BorderRenderController+ToolbarDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 10/08/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import UberSegmentedControl

extension BorderController: BorderToolbarDelegate {
    func borderToolbarWidthButtonTapped(_ toolbar: BorderToolbar) {
        setupDetailToolbarUsingSelectedItem()
    }

    func borderToolbarOpacityButtonTapped(_ toolbar: BorderToolbar) {
        setupDetailToolbarUsingSelectedItem()
    }

    func borderToolbarColorButtonTapped(_ toolbar: BorderToolbar) {
        guard let control = toolbar.colorControl else { return }

        let dimension: CGFloat = 270

        let controller = ColorPickerViewController(color: toolbar.color, dimension: dimension) { fontColor in
            self.toolbar.color = fontColor
            self.renderNode.color = fontColor
            self.updateRenderNode()
        }

        controller.preferredContentSize = CGSize(width: dimension + 30, height: dimension + 30)

        showPopup(controller, sourceView: control)
    }
}

extension BorderController: BoundedRangeCommandToolbarDelegate {
    func toolbarSliderChanged(slider: UISlider, for command: BoundedRangeCommand) {
        switch command {
        case is Module.Commands.Width:
            renderNode.width = CGFloat(slider.value)
        case is Module.Commands.Opacity:
            renderNode.opacity = CGFloat(slider.value)
        default:
            break
        }
    }

    func toolbarSliderFinishedChanging(slider: UISlider, for command: BoundedRangeCommand) {
        updateRenderNode()
    }
}


private extension BorderController {
    func setupDetailToolbarUsingSelectedItem() {
        guard let command = toolbar.selectedDescriptibleItem as? BoundedRangeCommand else { return }

        setupDetailToolbar(for: command)
    }

    func updateRenderNode() {
        renderNode.group?.nodeFinishedChanging(node: renderNode, change: nil)
    }
}
