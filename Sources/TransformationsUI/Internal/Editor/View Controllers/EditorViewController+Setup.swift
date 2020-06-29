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
        setupPipeline()
        setupView()
        setupAndActivateOverviewModule()

        titleToolbar.delegate = self
        renderPipeline.delegate = self

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
        renderPipeline.addNode(node: overviewModule.viewController.getRenderNode())
        activate(module: overviewModule)
    }

    func setupPipeline() {
        for module in modules {
            renderPipeline.addNode(node: module.viewController.getRenderNode())
        }
    }

    func setupView() {
        view.backgroundColor = Constants.Color.background
        moduleContainerView.backgroundColor = Constants.Color.moduleBackground

        stackView.addArrangedSubview(titleToolbar)
        stackView.addArrangedSubview(moduleContainerView)

        view.fill(with: stackView, withSafeAreaRespecting: true, activate: true)
    }
}
