//
//  FiltersController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 20/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

class FiltersController: EditorModuleController {
    typealias Module = Modules.Filters

    // MARK: - Internal Properties

    let module: Module
    let renderNode: FiltersRenderNode
    let viewSource: ModuleViewSource

    private(set) lazy var toolbar: StandardToolbar = {
        let toolbar = StandardToolbar(items: module.commands, style: .largeCommands)

        toolbar.delegate = self
        toolbar.backgroundColor = Constants.Color.secondaryBackground

        return toolbar
    }()

    // MARK: - View Overrides

    func getModule() -> EditorModule? { module }
    func getRenderNode() -> RenderNode? { renderNode }
    func editorDidRestoreSnapshot() { resetToolbar() }

    // MARK: - Lifecycle

    required init(renderNode: RenderNode?, module: EditorModule, viewSource: ModuleViewSource) {
        self.module = module as! Module
        self.renderNode = renderNode as! FiltersRenderNode
        self.viewSource = viewSource
        setup()
    }

    deinit {
        cleanup()
    }
}

// MARK: - Private Functions

private extension FiltersController {
    func setup() {
        viewSource.stackView.addArrangedSubview(toolbar)
        setupToolbarItemIcons()
        resetToolbar()
    }

    func cleanup() {
        toolbar.removeFromSuperview()
    }

    func resetToolbar() {
        // Select item in toolbar based on current renderNode's `filterType`.
        let filterType = renderNode.filterType
        // Linear search over module commands to find the one that represents the `filterType` we are looking for,
        // and extract the index. That index is guaranteed to match the toolbar item's index we wish to select.
        if let idx = (module.commands.firstIndex { ($0 as? Module.Commands.Filter)?.type == filterType }) {
            toolbar.selectedItem = toolbar.items[idx]
        }
    }

    func setupToolbarItemIcons() {
        guard
            let thumbImage = renderNode.inputImage.squareCropped()?.resized(to: Constants.Size.toolbarIcon),
            let cgImage = CIContext().createCGImage(thumbImage, from: thumbImage.extent)
        else {
            return
        }

        for button in (toolbar.items.compactMap { $0 as? UIButton }) {
            let command = module.commands[button.tag]

            switch command {
            case let filter as Module.Commands.Filter:
                let ciImage = CIImage(cgImage: cgImage).applying(filterType: filter.type)

                DispatchQueue.main.async {
                    if let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) {
                        button.setImage(UIImage(cgImage: cgImage).withRenderingMode(.alwaysOriginal), for: .normal)
                    }
                }
            default:
                break
            }
        }
    }
}

// MARK: - Editable Conformance

extension FiltersController: Editable {
    func applyEditing() { /* NO-OP */ }
    func cancelEditing() { /* NO-OP */ }
}
