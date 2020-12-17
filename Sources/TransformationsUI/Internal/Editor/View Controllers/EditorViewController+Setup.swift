//
//  EditorViewController+Setup.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

extension EditorViewController {
    func setup() {
        attachModuleViewController()
        setupPipeline()
        setupView()
        setupAndActivateOverviewModule()

        editorUndoManager = EditorUndoManager(initialStep: renderPipeline.snapshot())
        editorUndoManager?.delegate = self
        updateUndoRedoButtons()
    }

    func updateUndoRedoButtons() {
        titleToolbar.undo.isEnabled = editorUndoManager?.canUndo() ?? false
        titleToolbar.redo.isEnabled = editorUndoManager?.canRedo() ?? false
    }
}

private extension EditorViewController {
    func setupAndActivateOverviewModule() {
        activate(module: overviewModule)
    }

    func setupPipeline() {
        renderPipeline.delegate = self

        for module in modules {
            guard module.autocreatesNode == true, let node = module.nodeType?.init() else { continue }

            moduleUUIDToRenderNode[module.uuid] = node

            switch module.nodeCategory {
            case .image:
                renderPipeline.imageRenderNodeGroup.add(node: node)
            case .object:
                renderPipeline.objectRenderNodeGroup.add(node: node)
            case .overlay:
                renderPipeline.overlayRenderNodeGroup.add(node: node)
            default:
                break
            }
        }

        moduleViewController.canvasView = renderPipeline.view
    }

    func setupView() {
        view.backgroundColor = Constants.Color.background
        moduleContainerView.backgroundColor = Constants.Color.moduleBackground

        stackView.addArrangedSubview(titleToolbar)
        stackView.addArrangedSubview(moduleContainerView)

        view.fill(with: stackView, withSafeAreaRespecting: true, activate: true)
    }
}
