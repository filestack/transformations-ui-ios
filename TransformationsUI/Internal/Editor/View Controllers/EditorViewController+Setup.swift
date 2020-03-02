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
        setupModules()
        setupView()

        titleToolbar.delegate = self
        modulesToolbar.delegate = self
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
    func setupPipeline() {
        for module in modules {
            renderPipeline.addNode(node: module.viewController.getRenderNode())
        }
    }

    func setupModules() {
        var moduleItems = [UIView]()

        for (idx, module) in modules.enumerated() {
            guard let icon = module.icon else { continue }

            let item = modulesToolbar.moduleButton(using: icon)

            item.tag = idx
            item.tintColor = .white

            moduleItems.append(item)
        }

        modulesToolbar.setItems(moduleItems)

        // Show first module by default.
        if let module = modules.first {
            activate(module: module)
        }
    }

    func setupView() {
        view.backgroundColor = Constants.backgroundColor
        setupContainerView()
        setupModulesToolbar()
        setupTitleToolbar()
    }

    func setupContainerView() {
        // On .. x hR
        defineConstraints(width: .unspecified, height: .regular) {
            var constraints = [NSLayoutConstraint]()

            constraints.append(contentsOf: view.fill(with: containerView,
                                                     connectingEdges: [.left, .right],
                                                     inset: 0,
                                                     withSafeAreaRespecting: true))

            constraints.append(contentsOf: view.fill(with: containerView,
                                                     connectingEdges: [.top, .bottom],
                                                     inset: Constants.toolbarSize,
                                                     withSafeAreaRespecting: true))

            return constraints
        }

        // On .. x hC
        defineConstraints(width: .unspecified, height: .compact) {
            var constraints = [NSLayoutConstraint]()

            constraints.append(contentsOf: view.fill(with: containerView,
                                                     connectingEdges: [.left, .top, .right],
                                                     inset: Constants.toolbarSize,
                                                     withSafeAreaRespecting: true))

            constraints.append(contentsOf: view.fill(with: containerView,
                                                     connectingEdges: [.bottom],
                                                     inset: 0,
                                                     withSafeAreaRespecting: true))

            return constraints
        }
    }

    func setupTitleToolbar() {
        var constraints = [NSLayoutConstraint]()

        constraints.append(contentsOf: view.fill(with: titleToolbar, connectingEdges: [.top],
                                                 inset: 0,
                                                 withSafeAreaRespecting: true))

        constraints.append(contentsOf: view.fill(with: titleToolbar, connectingEdges: [.left, .right],
                                                 inset: 0,
                                                 withSafeAreaRespecting: true))

        constraints.append(titleToolbar.heightAnchor.constraint(equalToConstant: Constants.toolbarSize))

        for constraint in constraints {
            constraint.isActive = true
        }
    }

    func setupModulesToolbar() {
        // On hR — anchor toolbar to the bottom
        defineConstraints(width: .unspecified, height: .regular) {
            var constraints = [NSLayoutConstraint]()

            constraints.append(contentsOf: view.fill(with: modulesToolbar, connectingEdges: [.bottom],
                                                     inset: 0,
                                                     withSafeAreaRespecting: true))

            constraints.append(contentsOf: view.fill(with: modulesToolbar, connectingEdges: [.left, .right],
                                                     inset: 0,
                                                     withSafeAreaRespecting: true))

            constraints.append(modulesToolbar.heightAnchor.constraint(equalToConstant: Constants.toolbarSize))

            return constraints
        }

        // On hC — anchor toolbar to the right
        defineConstraints(width: .unspecified, height: .compact) {
            var constraints = [NSLayoutConstraint]()

            constraints.append(contentsOf: view.fill(with: modulesToolbar, connectingEdges: [.right],
                                                     inset: 0,
                                                     withSafeAreaRespecting: true))

            constraints.append(contentsOf: view.fill(with: modulesToolbar, connectingEdges: [.top, .bottom],
                                                     inset: 0,
                                                     withSafeAreaRespecting: true))

            constraints.append(modulesToolbar.widthAnchor.constraint(equalToConstant: Constants.toolbarSize))

            return constraints
        }
    }
}
