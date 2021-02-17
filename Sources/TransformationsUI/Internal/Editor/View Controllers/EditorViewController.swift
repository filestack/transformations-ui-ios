//
//  EditorViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

final class EditorViewController: UIViewController, DiscardApplyToolbarDelegate, TitleToolbarDelegate {
    // MARK: - Internal Properties

    lazy var titleToolbar: TitleToolbar = {
        let toolbar = TitleToolbar(style: .default)

        toolbar.delegate = self

        return toolbar
    }()

    let renderPipeline: RenderPipeline
    let modules: [EditorModule]
    let moduleViewController = ModuleViewController()
    let moduleContainerView = UIView()
    var editorUndoManager: EditorUndoManager?
    var moduleUUIDToRenderNode = [UUID:RenderNode]()

    lazy var overviewModule: Modules.Overview = Modules.Overview(modules: modules, pipeline: renderPipeline)

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
    private var activeEditableModuleController: Editable? { moduleViewController.activeModuleController as? Editable }
    private var discardApplyToolbar: DiscardApplyToolbar? = nil

    // MARK: - Lifecycle

    init?(image: UIImage, config: Config, completion: @escaping (UIImage?) -> Void) {
        guard
            image.size.width < Constants.Size.maxImageInputSize.width,
            image.size.height < Constants.Size.maxImageInputSize.height
        else {
            return nil
        }

        guard let renderPipeline = RenderPipeline(inputImage: image) else { return nil }

        self.config = config
        self.modules = config.modules.all.compactMap { $0.isEnabled ? $0 : nil }
        self.renderPipeline = renderPipeline
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

    func attachModuleViewController() {
        addChild(moduleViewController)

        moduleContainerView.fill(with: moduleViewController.view, activate: true)
        moduleViewController.didMove(toParent: self)
        moduleViewController.discardApplyDelegate = self
    }

    func activate(module: EditorModule, renderNode: RenderNode? = nil) {
        let moduleController = module.controllerType.init(renderNode: renderNode ?? self.renderNode(for: module),
                                                          module: module,
                                                          viewSource: moduleViewController)

        moduleViewController.activeModuleController = moduleController

        // If module VC has a custom title view, let's add it to the title toolbar.
        if let titleView = moduleController.getTitleView() {
            titleToolbar.setItems([titleView])
        } else {
            titleToolbar.setItems([])
        }

        // Add or remove "discard/apply" toolbar depending on whether module is editable.
        if moduleController is Editable {
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

        if let overviewController = moduleController as? OverviewController {
            overviewController.delegate = self
        }
    }

    // MARK: - DiscardApplyToolbar Delegate

    func applySelected(sender: UIButton?) {
        activeEditableModuleController?.applyEditing()

        // Take a snapshot from rendering pipeline and register permanent undo step.
        editorUndoManager?.register(step: renderPipeline.snapshot())

        activateOverviewModule()
    }

    func discardSelected(sender: UIButton?) {
        activeEditableModuleController?.cancelEditing()

        // Remove transitory steps from undo manager.
        editorUndoManager?.removeTransitorySteps()

        // Restore last state from undo manager.
        if let state = editorUndoManager?.currentStep {
            renderPipeline.restore(from: state)
        }

        activateOverviewModule()
    }

    // MARK: - TitleToolbar Delegate

    func saveSelected(sender: UIButton) {
        activeEditableModuleController?.applyEditing()
        let editedImage = renderPipeline.outputImage

        moduleViewController.activeModuleController = nil
        moduleViewController.view.removeFromSuperview()
        moduleViewController.removeFromParent()

        dismiss(animated: true) {
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

        if let state = editorUndoManager?.currentStep {
            renderPipeline.restore(from: state)

            DispatchQueue.main.async {
                self.moduleViewController.activeModuleController?.editorDidRestoreSnapshot()
            }
        }
    }

    func redoSelected(sender: UIButton) {
        editorUndoManager?.redo()

        if let state = editorUndoManager?.currentStep {
            renderPipeline.restore(from: state)

            DispatchQueue.main.async {
                self.moduleViewController.activeModuleController?.editorDidRestoreSnapshot()
            }
        }
    }
}

// MARK: - Private Functions

private extension EditorViewController {
    func activateOverviewModule() {
        // Try to get object render node from active module.
        let objectRenderNode = moduleViewController.activeModuleController?.getRenderNode() as? ObjectRenderNode

        // Activate module
        activate(module: overviewModule, renderNode: objectRenderNode)
    }

    func renderNode(for module: EditorModule) -> RenderNode? {
        if let moduleRenderNode = moduleUUIDToRenderNode[module.uuid] {
            return moduleRenderNode
        }

        if !module.autocreatesNode {
            switch module.nodeCategory {
            case .object:
                let renderNodeGroup = renderPipeline.objectRenderNodeGroup
                let renderNode = module.controllerType.renderNode(for: module, in: renderNodeGroup)

                return renderNode
            default:
                break
            }
        }

        return nil
    }
}

// MARK: - RenderPipeline Delegate

extension EditorViewController: RenderPipelineDelegate {
    func pipelineChanged(pipeline: RenderPipeline) {
        // Take a snapshot from rendering pipeline and register transitory undo step.
        let snapshot = pipeline.snapshot()

        editorUndoManager?.register(step: snapshot, transitory: true)
    }
}

// MARK: - EditorUndoManager Delegate

extension EditorViewController: EditorUndoManagerDelegate {
    func undoManagerChanged(editorUndoManager: EditorUndoManager) {
        updateUndoRedoButtons()
    }
}

// MARK: - OverviewController Delegate

extension EditorViewController: OverviewControllerDelegate {
    func overviewSelectedModule(module: EditorModule, renderNode: RenderNode?) {
        activate(module: module, renderNode: renderNode)
    }

    func overviewCommittedChange() {
        editorUndoManager?.register(step: renderPipeline.snapshot())
    }
}
