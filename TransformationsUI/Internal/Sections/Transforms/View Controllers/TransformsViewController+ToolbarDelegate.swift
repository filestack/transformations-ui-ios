//
//  TransformsViewController+ToolbarDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension TransformsViewController: TransformsToolbarDelegate {
    private enum EditorCommand {
        case rotate(clockwise: Bool)
        case crop(insets: UIEdgeInsets)
        case circled(center: CGPoint, radius: CGFloat)
    }

    func rotateSelected() {
        perform(command: .rotate(clockwise: false))
        cropHandler.rotateCounterClockwise()
        circleHandler.rotateCounterClockwise()
    }

    func cropSelected() {
        switch editMode {
        case .crop: editMode = .none
        case .circle, .none: editMode = .crop
        }
    }

    func circleSelected() {
        switch editMode {
        case .circle: editMode = .none
        case .crop, .none: editMode = .circle
        }
    }

    func saveSelected() {
        switch editMode {
        case .crop: perform(command: .crop(insets: cropHandler.actualEdgeInsets))
        case .circle: perform(command: .circled(center: circleHandler.actualCenter, radius: circleHandler.actualRadius))
        case .none: return
        }

        editMode = .none
    }

    // MARK: - Private Functions

    private func perform(command: EditorCommand) {
        guard let renderNode = renderNode as? TransformsRenderNode else { return }

        switch command {
        case let .rotate(clockwise):
            renderNode.rotate(clockwise: clockwise)
        case let .crop(insets):
            renderNode.crop(insets: insets)
        case let .circled(center, radius):
            renderNode.circled(center: center, radius: radius)
        }

        editMode = .none
        cropHandler.reset()
        circleHandler.reset()

        renderNode.pipeline?.nodeFinishedChanging(node: renderNode)
    }
}
