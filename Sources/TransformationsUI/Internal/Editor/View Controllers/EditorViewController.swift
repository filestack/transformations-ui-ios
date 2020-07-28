//
//  EditorViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

final class EditorViewController: ArrangeableViewController {
    // MARK: - Internal Properties

    lazy var titleToolbar: TitleToolbar = {
        let toolbar = TitleToolbar(style: .default)

        toolbar.delegate = self

        return toolbar
    }()

    let renderPipeline: BasicRenderPipeline
    let modules: [EditorModule]
    let moduleContainerView = UIView()
    var editorUndoManager: EditorUndoManager?

    lazy var overviewModule: StandardModules.Overview = {
        let viewController = OverviewViewController(modules: modules, delegate: self)

        return StandardModules.Overview(using: viewController)
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill

        return stackView
    }()

    // MARK: - Private Properties

    private let config: Config
    private var completion: ((UIImage?) -> Void)?
    private var activeModule: EditorModule?
    private var activeEditableModuleVC: Editable? { activeModule?.viewController as? Editable }
    private var discardApplyToolbar: DiscardApplyToolbar? = nil

    // MARK: - Lifecycle

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

    // MARK: - View Overrides

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch UIScreen.main.traitCollection.userInterfaceIdiom {
        case .pad:
            return .all
        default:
            return [.portrait, .portraitUpsideDown]
        }
    }

    // MARK: - Public Functions

    func activate(module: EditorModule) {
        // Remove any previously added module VC's.
        for child in (children.compactMap { $0 as? EditorModuleVC }) {
            child.removeFromParent()
            child.view.removeFromSuperview()
        }

        // Add module as a child VC.
        addChild(module.viewController)

        moduleContainerView.fill(with: module.viewController.view, activate: true)
        activeModule = module

        // Notify that module VC moved to a new parent.
        module.viewController.didMove(toParent: self)
        module.viewController.discardApplyDelegate = self

        // If module VC has a custom title view, let's add it to the title toolbar.
        if let titleView = module.viewController.getTitleView() {
            titleToolbar.setItems([titleView])
        } else {
            titleToolbar.setItems([])
        }

        // Add or remove "discard/apply" toolbar depending on whether module is editable.
        if module.viewController is Editable {
            if discardApplyToolbar == nil {
                let toolbar = DiscardApplyToolbar()

                toolbar.delegate = self
                stackView.addArrangedSubview(toolbar)
                self.discardApplyToolbar = toolbar
            }
        } else if let discardApplyToolbar = discardApplyToolbar {
            stackView.removeArrangedSubview(discardApplyToolbar)
            discardApplyToolbar.removeFromSuperview()

            self.discardApplyToolbar = nil
        }
    }
}

// MARK: - DiscardApplyToolbar Delegate

extension EditorViewController: DiscardApplyToolbarDelegate {
    func applySelected(sender: UIButton) {
        activeEditableModuleVC?.applyEditing()

        // Take a snapshot from rendering pipeline and register permanent undo step.
        editorUndoManager?.register(step: renderPipeline.snapshot())

        activate(module: overviewModule)
    }

    func discardSelected(sender: UIButton) {
        activeEditableModuleVC?.cancelEditing()

        editorUndoManager?.removeTransitorySteps()

        // Restore last state from undo manager.
        if let state = editorUndoManager?.currentStep {
            renderPipeline.restore(from: state)
        }

        activate(module: overviewModule)
    }
}

// MARK: - RenderPipeline Delegate

extension EditorViewController: RenderPipelineDelegate {
    func outputChanged(pipeline: RenderPipeline) {
        // Update active module VC's image view.
        DispatchQueue.main.async {
            self.activeModule?.viewController.imageView.image = pipeline.outputImage
        }
    }

    func outputFinishedChanging(pipeline: RenderPipeline) {
        // Take a snapshot from rendering pipeline and register transitory undo step.
        guard let snapshot = (pipeline as? Snapshotable)?.snapshot() else { return }

        editorUndoManager?.register(step: snapshot, transitory: true)
    }
}

// MARK: - EditorUndoManager Delegate

extension EditorViewController: EditorUndoManagerDelegate {
    func undoManagerChanged(editorUndoManager: EditorUndoManager) {
        updateUndoRedoButtons()
    }
}

// MARK: - TitleToolbar Delegate

extension EditorViewController: TitleToolbarDelegate {
    func saveSelected(sender: UIButton) {
        activeEditableModuleVC?.applyEditing()

        dismiss(animated: true) {
            let editedImage = UIImage(ciImage: self.renderPipeline.outputImage).cgImageBackedCopy()
            self.completion?(editedImage)
        }
    }

    func cancelSelected(sender: UIButton) {
        dismiss(animated: true) {
            self.completion?(nil)
        }
    }

    func undoSelected(sender: UIButton) {
        editorUndoManager?.undo()
        activeEditableModuleVC?.cancelEditing()

        if let state = editorUndoManager?.currentStep {
            renderPipeline.restore(from: state)
            
            DispatchQueue.main.async {
                self.activeModule?.viewController.editorDidRestoreSnapshot()
            }
        }
    }

    func redoSelected(sender: UIButton) {
        editorUndoManager?.redo()
        activeEditableModuleVC?.cancelEditing()

        if let state = editorUndoManager?.currentStep {
            renderPipeline.restore(from: state)
            
            DispatchQueue.main.async {
                self.activeModule?.viewController.editorDidRestoreSnapshot()
            }
        }
    }
}

// MARK: - OverviewViewController Delegate

extension EditorViewController: OverviewViewControllerDelegate {
    func moduleSelected(module: EditorModule) {
        activate(module: module)
    }
}
