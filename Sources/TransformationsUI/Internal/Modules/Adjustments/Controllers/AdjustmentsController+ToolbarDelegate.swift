//
//  AdjustmentsController+ToolbarDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 28/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension AdjustmentsController: StandardToolbarDelegate {
    func toolbarItemSelected(toolbar: StandardToolbar, item: DescriptibleEditorItem, control: UIControl) {
        guard let boundedRangeCommand = item as? BoundedRangeCommand else { return }

        setupDetailToolbar(for: boundedRangeCommand)
    }
}

extension AdjustmentsController: BoundedRangeCommandToolbarDelegate {
    func toolbarSliderChanged(slider: UISlider, for command: BoundedRangeCommand) {
        switch command {
        case is Module.Commands.Blur:
            renderNode.blurAmount = Double(slider.value)
        case is Module.Commands.Brightness:
            renderNode.brightness = Double(slider.value)
        case is Module.Commands.Contrast:
            renderNode.contrast = Double(slider.value)
        case is Module.Commands.Gamma:
            let value = CGFloat(slider.value)
            let component = RGBComponent(rawValue: slider.tag)

            switch component {
            case .red:
                renderNode.gamma = CIVector(x: value, y: renderNode.gamma.y, z: renderNode.gamma.z)
            case .green:
                renderNode.gamma = CIVector(x: renderNode.gamma.x, y: value, z: renderNode.gamma.z)
            case .blue:
                renderNode.gamma = CIVector(x: renderNode.gamma.x, y: renderNode.gamma.y, z: value)
            default:
                break
            }
        case is Module.Commands.HueRotation:
            renderNode.hueRotationAngle = Double(slider.value)
        case is Module.Commands.Pixelate:
            renderNode.pixelate = Double(slider.value)
        case is Module.Commands.Saturation:
            renderNode.saturation = Double(slider.value)
        default:
            break
        }

        renderNode.group?.nodeChanged(node: renderNode)
    }

    func toolbarSliderFinishedChanging(slider: UISlider, for command: BoundedRangeCommand) {
        renderNode.group?.nodeFinishedChanging(node: renderNode, change: nil)
    }
}
