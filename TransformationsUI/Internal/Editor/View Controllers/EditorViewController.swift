//
//  EditorViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

final class EditorViewController: ArrangeableViewController, UIGestureRecognizerDelegate {
    // MARK: - Internal Properties

    let titleToolbar = TitleToolbar()
    let renderPipeline: BasicRenderPipeline
    let modules: [EditorModule]
    let moduleContainerView = UIView()
    var editorUndoManager: EditorUndoManager?

    lazy var overviewModule: StandardModules.Overview = {
        let viewController = OverviewViewController(modules: modules)
        viewController.delegate = self

        return StandardModules.Overview(using: viewController)
    }()

    // MARK: - Private Properties

    private let config: Config
    private var completion: ((UIImage?) -> Void)?
    private var activeModule: EditorModule?

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

    // MARK: - View Overrides

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch UIScreen.main.traitCollection.userInterfaceIdiom {
        case .pad:
            return .all
        default:
            return [.portrait, .portraitUpsideDown]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
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
        module.viewController.delegate = self

        // If module VC has a custom title view, let's add it to the title toolbar.
        if let titleView = module.viewController.getTitleView() {
            titleToolbar.setItems([titleView])
        } else {
            titleToolbar.setItems([])
        }
    }
}

extension EditorViewController: RenderPipelineDelegate {
    func outputChanged(pipeline: RenderPipeline) {
        // Update active module VC's image view.
        DispatchQueue.main.async {
            self.activeModule?.viewController.updateImageView()
        }
    }

    func outputFinishedChanging(pipeline: RenderPipeline) {
        // Take a snapshot from rendering pipeline and register undo step.
        guard let snapshot = (pipeline as? Snapshotable)?.snapshot() else { return }

        editorUndoManager?.register(step: snapshot)
    }
}

extension EditorViewController: EditorUndoManagerDelegate {
    func undoManagerChanged(editorUndoManager: EditorUndoManager) {
        updateUndoRedoButtons()
    }
}

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

        if let state = editorUndoManager?.current {
            renderPipeline.restore(from: state)
            
            DispatchQueue.main.async {
                self.activeModule?.viewController.editorRestoredSnapshot()
            }
        }
    }

    func redoSelected(sender: UIButton) {
        editorUndoManager?.redo()
        activeEditableModuleVC?.cancelEditing()

        if let state = editorUndoManager?.current {
            renderPipeline.restore(from: state)
            
            DispatchQueue.main.async {
                self.activeModule?.viewController.editorRestoredSnapshot()
            }
        }
    }
}

extension EditorViewController: OverviewViewControllerDelegate, EditorModuleVCDelegate {
    func moduleSelected(module: EditorModule) {
        activate(module: module)
    }

    func moduleWantsToApplyChanges(module: EditorModule) {
        (module.viewController as? Editable)?.applyEditing()

        activate(module: overviewModule)
    }

    func moduleWantsToDiscardChanges(module: EditorModule) {
        (module.viewController as? Editable)?.cancelEditing()

        // Restore last state from undo manager.
        if let state = editorUndoManager?.current {
            renderPipeline.restore(from: state)
        }

        activate(module: overviewModule)
    }
}
