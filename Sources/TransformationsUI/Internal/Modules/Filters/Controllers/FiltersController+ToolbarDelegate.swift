//
//  FiltersController+ToolbarDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 20/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension FiltersController: StandardToolbarDelegate {
    func toolbarItemSelected(toolbar: StandardToolbar, item: DescriptibleEditorItem, control: UIControl) {
        guard let command = item as? EditorModuleCommand else { return }

        perform(command: command)
    }
}

// MARK: - Private Functions

private extension FiltersController {
    func perform(command: EditorModuleCommand) {
        switch command {
        case let filter as Module.Commands.Filter:
            renderNode.filterType = filter.type
        default:
            break
        }

        renderNode.group?.nodeFinishedChanging(node: renderNode, change: nil)
    }
}
