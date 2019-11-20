//
//  EditorViewController.swift
//  TransformationsUI
//
//  Created by Mihály Papp on 03/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

final class EditorViewController: ArrangeableViewController, UIGestureRecognizerDelegate {
    // MARK: - Internal Properties

    let titleToolbar = TitleToolbar()
    let modulesToolbar = ModulesToolbar()

    let renderPipeline: BasicRenderPipeline
    let modules: [EditorModule]
    let containerView = UIView()
    var editorUndoManager: EditorUndoManager?

    // MARK: - Private Properties

    private let config: Config
    private var completion: ((UIImage?) -> Void)?
    private var isEditingObserver: NSKeyValueObservation?

    private var activeModule: EditorModule? {
        didSet { setupEditingObserver() }
    }

    private var activeEditableModuleVC: Editable? {
        activeModule?.viewController as? Editable
    }

    // MARK: - Lifecycle Functions

    init?(image: UIImage, config: Config, completion: @escaping (UIImage?) -> Void) {
        guard let ciImage = image.ciImageBackedCopy()?.ciImage else { return nil }

        self.config = config
        self.modules = config.modules.all.compactMap { $0.isEnabled ? $0 : nil }
        self.renderPipeline = BasicRenderPipeline(inputImage: ciImage)
        self.completion = completion

        super.init(nibName: nil, bundle: nil)

        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Functions

    func activate(module: EditorModule) {
        // Remove any previously added module vc's.
        for child in (children.compactMap { $0 as? EditorModuleVC }) {
            child.removeFromParent()
            child.view.removeFromSuperview()
        }

        // Add module as a child vc.
        addChild(module.viewController)

        titleToolbar.title = module.title
        containerView.fill(with: module.viewController.view, activate: true)
        activeModule = module

        // Notify that module vc moved to a new parent.
        module.viewController.didMove(toParent: self)
    }
}

private extension EditorViewController {
    func setupEditingObserver() {
        guard let vc: UIViewController = activeModule?.viewController else { return }

        isEditingObserver = vc.observe(\.isEditing, options: [.new]) { _, change in
            guard let isEditing = change.newValue else { return }

            self.titleToolbar.isEditing = isEditing
            self.modulesToolbar.isEditing = isEditing
        }
    }
}

extension EditorViewController: RenderPipelineDelegate {
    func outputChanged(pipeline: RenderPipeline) {
        guard let snapshot = (pipeline as? Snapshotable)?.snapshot() else { return }

        editorUndoManager?.register(step: snapshot)
    }
}

extension EditorViewController: EditorUndoManagerDelegate {
    func undoManagerChanged(editorUndoManager: EditorUndoManager) {
        updateUndoRedoButtons()
    }
}

extension EditorViewController: ModulesToolbarDelegate, TitleToolbarDelegate {
    func doneSelected(sender: UIButton) {
        switch activeEditableModuleVC?.isEditing {
        case true:
            activeEditableModuleVC?.applyEditing()
        case false:
            fallthrough
        default:
            dismiss(animated: true) {
                let editedImage = UIImage(ciImage: self.renderPipeline.outputImage).cgImageBackedCopy()
                self.completion?(editedImage)
            }
        }
    }

    func cancelSelected(sender: UIButton) {
        dismiss(animated: true) {
            self.completion?(nil)
        }
    }

    func moduleSelected(sender: UIButton) {
        activate(module: modules[sender.tag])
    }

    func undoSelected(sender: UIButton) {
        editorUndoManager?.undo()
        activeEditableModuleVC?.applyEditing()

        if let state = editorUndoManager?.current {
            renderPipeline.restore(from: state)
        }
    }

    func redoSelected(sender: UIButton) {
        editorUndoManager?.redo()
        activeEditableModuleVC?.applyEditing()

        if let state = editorUndoManager?.current {
            renderPipeline.restore(from: state)
        }
    }
}
