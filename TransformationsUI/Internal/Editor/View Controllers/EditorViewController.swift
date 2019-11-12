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
    let modulesToolbar = ModuleToolbar()

    let renderPipeline: BasicRenderPipeline
    let modules: [UIViewController & EditorModule]
    let containerView = UIView()
    var editorUndoManager: EditorUndoManager?

    // MARK: - Private Properties

    private var completion: ((UIImage?) -> Void)?
    private var isEditingObserver: NSKeyValueObservation?

    private var activeModule: EditorModule? {
        didSet { setupEditingObserver() }
    }

    // MARK: - Lifecycle Functions

    init?(image: UIImage, modules: [EditorModule], completion: @escaping (UIImage?) -> Void) {
        guard let ciImage = image.ciImageBackedCopy()?.ciImage else { return nil }

        self.modules = modules
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
        titleToolbar.title = module.title
        containerView.fill(with: module.view, activate: true)
        activeModule = module
    }
}

private extension EditorViewController {
    func setupEditingObserver() {
        guard let vc: UIViewController = activeModule else { return }

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
        switch (activeModule as? Editable)?.isEditing {
        case true:
            (activeModule as? Editable)?.applyEditing()
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
        (activeModule as? Editable)?.applyEditing()

        if let state = editorUndoManager?.current {
            renderPipeline.restore(from: state)
        }
    }

    func redoSelected(sender: UIButton) {
        editorUndoManager?.redo()
        (activeModule as? Editable)?.applyEditing()

        if let state = editorUndoManager?.current {
            renderPipeline.restore(from: state)
        }
    }
}
