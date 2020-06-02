//
//  EditorViewController+Setup.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension EditorViewController {
    func setup() {
        setupPipeline()
        setupView()
        setupAndActivateOverviewModule()

        titleToolbar.delegate = self
        renderPipeline.delegate = self

        editorUndoManager = EditorUndoManager(state: renderPipeline.snapshot())
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
        view.backgroundColor = Constants.backgroundColor
        canvasView.backgroundColor = Constants.canvasBackgroundColor

        setupCanvasViewConstraints()
        setupTitleToolbarConstraints()
    }

    func setupCanvasViewConstraints() {
        var constraints = [NSLayoutConstraint]()

        constraints.append(contentsOf: view.fill(with: canvasView,
                                                 connectingEdges: [.left, .right],
                                                 inset: 0,
                                                 withSafeAreaRespecting: true))

        constraints.append(contentsOf: view.fill(with: canvasView,
                                                 connectingEdges: [.top],
                                                 inset: Constants.toolbarSize.height,
                                                 withSafeAreaRespecting: true))

        constraints.append(contentsOf: view.fill(with: canvasView,
                                                 connectingEdges: [.bottom],
                                                 inset: 0,
                                                 withSafeAreaRespecting: true))

        for constraint in constraints {
            constraint.isActive = true
        }
    }

    func setupTitleToolbarConstraints() {
        var constraints = [NSLayoutConstraint]()

        constraints.append(contentsOf: view.fill(with: titleToolbar, connectingEdges: [.top],
                                                 inset: 0,
                                                 withSafeAreaRespecting: true))

        constraints.append(contentsOf: view.fill(with: titleToolbar, connectingEdges: [.left, .right],
                                                 inset: 0,
                                                 withSafeAreaRespecting: true))

        constraints.append(titleToolbar.heightAnchor.constraint(equalToConstant: Constants.toolbarSize.width))

        for constraint in constraints {
            constraint.isActive = true
        }
    }
}
