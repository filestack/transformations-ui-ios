//
//  EditorViewController.swift
//  TransformationsUI
//
//  Created by Mihály Papp on 03/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

final class EditorViewController: UIViewController, UIGestureRecognizerDelegate {
    let sectionsToolbar = SectionsToolbar()
    let undoRedoToolbar = UndoRedoToolbar()
    let renderPipeline: BasicRenderPipeline
    let sections: [UIViewController & Section]
    let containerView = UIView()

    var editorUndoManager: EditorUndoManager?
    var completion: ((UIImage?) -> Void)?

    init?(image: UIImage, sections: [UIViewController & Section], completion: @escaping (UIImage?) -> Void) {
        guard let ciImage = image.ciImageBackedCopy()?.ciImage else { return nil }

        self.sections = sections
        self.renderPipeline = BasicRenderPipeline(inputImage: ciImage)
        self.completion = completion

        super.init(nibName: nil, bundle: nil)

        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EditorViewController {
    func setup() {
        setupPipeline()
        setupSections()
        setupView()

        renderPipeline.delegate = self
        editorUndoManager = EditorUndoManager(state: renderPipeline.snapshot())
        editorUndoManager?.delegate = self
    }

    func setupPipeline() {
        for section in sections {
            renderPipeline.addNode(node: section.renderNode)
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
        undoRedoToolbar.setActions(showUndo: editorUndoManager.canUndo(), showRedo: editorUndoManager.canRedo())
    }
}
