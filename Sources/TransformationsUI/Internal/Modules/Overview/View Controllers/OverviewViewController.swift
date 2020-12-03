//
//  OverviewViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

protocol OverviewControllerDelegate: class {
    func overviewSelectedModule(module: EditorModule, renderNode: RenderNode?)
    func overviewCommittedChange()
}

class OverviewController: NSObject, EditorModuleController {
    // MARK: - Internal Properties

    weak var delegate: OverviewControllerDelegate?
    let viewSource: ModuleViewSource

    // MARK: - Private Properties

    private let module: StandardModules.Overview

    private lazy var modulesToolbar: StandardToolbar = {
        let toolbar = StandardToolbar(items: module.modules, style: .modules)

        toolbar.delegate = self

        return toolbar
    }()

    private lazy var objectToolbar: StandardToolbar = {
        let items = [
            ObjectToolbarItem(title: "Edit", icon: UIImage.fromBundle("icon-edit-object"), type: .edit),
            ObjectToolbarItem(title: "Delete", icon: UIImage.fromBundle("icon-delete-object"), type: .delete),
            ObjectToolbarItem(title: "Reset", icon: UIImage.fromBundle("icon-reset-transform-object"), type: .resetTransform),
            ObjectToolbarItem(title: "Back", icon: UIImage.fromBundle("icon-send-back-object"), type: .sendBack),
            ObjectToolbarItem(title: "Forward", icon: UIImage.fromBundle("icon-send-forward-object"), type: .sendForward)
        ]

        let toolbar = StandardToolbar(items: items, style: .commands)
        toolbar.delegate = self

        return toolbar
    }()

    private lazy var objectToolbarFXWrapperView: UIView = {
        let view = VisualFXWrapperView(wrapping: objectToolbar, usingBlurEffect: Constants.ViewEffects.blur)

        view.alpha = 0

        return view
    }()

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()

        recognizer.numberOfTapsRequired = 1
        recognizer.addTarget(self, action: #selector(handleTapGesture(recognizer:)))

        return recognizer
    }()

    private lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()

        recognizer.numberOfTapsRequired = 2
        recognizer.addTarget(self, action: #selector(handleDoubleTapGesture(recognizer:)))

        return recognizer
    }()

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()

        recognizer.delegate = self
        recognizer.addTarget(self, action: #selector(handlePanGesture(recognizer:)))

        return recognizer
    }()

    private lazy var customRecognizers = [tapGestureRecognizer, doubleTapGestureRecognizer, panGestureRecognizer]

    private var selectedObject: ObjectRenderNode? = nil {
        didSet {
            select(object: selectedObject)
        }
    }

    private var objectSelectionView: ObjectSelectionView? = nil {
        didSet {
            if objectSelectionView == nil {
                removeScrollViewObservers()
            } else {
                addScrollViewObservers()
            }
        }
    }
    private lazy var objectPanHandler = ObjectPanHandler(delegate: self)
    private let objectDragger = ObjectDragger()
    private var scrollViewObservers: [NSObjectProtocol] = []

    // MARK: - Lifecycle

    required init(renderNode: RenderNode?, module: EditorModule, viewSource: ModuleViewSource) {
        self.module = module as! StandardModules.Overview
        self.viewSource = viewSource

        super.init()

        setup()
    }

    deinit {
        cleanup()
    }

    // MARK: - Gesture Handling

    @objc func handleTapGesture(recognizer: UITapGestureRecognizer) {
        selectedObject = object(for: recognizer)
    }

    @objc func handleDoubleTapGesture(recognizer: UITapGestureRecognizer) {
        guard let object = object(for: recognizer), let module = self.module(for: object) else { return }

        selectModule(module, renderNode: object)
    }

    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        if objectPanHandler.object != nil {
            objectPanHandler.handle(recognizer: recognizer)
        } else {
            recognizer.state = .failed
        }
    }

    func editorDidRestoreSnapshot() {
        if let uuid = selectedObject?.uuid, let pipeline = module.pipeline {
            selectedObject = pipeline.objectRenderNodeGroup.node(with: uuid) as? ObjectRenderNode
        } else {
            selectedObject = nil
        }
    }
}

// MARK: - Private Functions

private extension OverviewController {
    func setup() {
        addGestureRecognizers()
        viewSource.stackView.addArrangedSubview(objectToolbarFXWrapperView)
        viewSource.stackView.addArrangedSubview(modulesToolbar)
    }

    func cleanup() {
        removeGestureRecognizers()
        removeObjectSelectionView()
        modulesToolbar.removeFromSuperview()
        objectToolbarFXWrapperView.removeFromSuperview()
        objectSelectionView?.removeFromSuperview()
    }

    func addGestureRecognizers() {
        viewSource.scrollView.addGestureRecognizer(tapGestureRecognizer)
        viewSource.scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
        viewSource.scrollView.addGestureRecognizer(panGestureRecognizer)
    }

    func removeGestureRecognizers() {
        viewSource.scrollView.removeGestureRecognizer(tapGestureRecognizer)
        viewSource.scrollView.removeGestureRecognizer(doubleTapGestureRecognizer)
        viewSource.scrollView.removeGestureRecognizer(panGestureRecognizer)
    }

    func module(for node: RenderGroupChildNode) -> EditorModule? {
        return module.modules.first { $0.nodeType == type(of: node)  }
    }

    func select(object: ObjectRenderNode? = nil) {
        objectPanHandler.object = object

        if object != nil {
            if objectSelectionView == nil {
                let objectSelectionView = ObjectSelectionView()

                viewSource.scrollView.addSubview(objectSelectionView)
                self.objectSelectionView = objectSelectionView
            }

            objectToolbarFXWrapperView.alpha = 1
            updateObjectSelectionView()
            updateObjectToolbar()
        } else {
            removeObjectSelectionView()
            objectToolbarFXWrapperView.alpha = 0
        }
    }

    func removeObjectSelectionView() {
        objectSelectionView?.removeFromSuperview()
        objectSelectionView = nil
    }

    func updateObjectSelectionView() {
        guard let objectSelectionView = objectSelectionView else { return }
        guard let object = selectedObject else { return }
        guard let canvasView = viewSource.canvasView else { return }

        objectSelectionView.center = viewSource.scrollView.convert(object.center, from: canvasView)
        objectSelectionView.bounds.size = viewSource.contentView.convert(object.bounds, from: canvasView).size
        objectSelectionView.transform = object.transform
    }

    func object(for recognizer: UIGestureRecognizer) -> ObjectRenderNode? {
        guard let pipeline = module.pipeline else { return nil }

        let location = recognizer.location(in: pipeline.view)

        return pipeline.objectRenderNodeGroup.node(at: location) as? ObjectRenderNode
    }

    func addScrollViewObservers() {
        removeScrollViewObservers()

        scrollViewObservers.append(viewSource.scrollView.observe(\.contentOffset, options: [.new]) { (scrollView, _) in
            if scrollView.isZooming {
                scrollView.bouncesZoom = false

                UIView.animate(withDuration: 0) {
                    UIView.setAnimationsEnabled(false)
                    self.objectSelectionView?.alpha = 0
                    UIView.setAnimationsEnabled(true)
                }
            } else {
                self.updateObjectSelectionView()

                UIView.animate(withDuration: 1) {
                    self.objectSelectionView?.alpha = 1
                } completion: { (_) in
                    scrollView.bouncesZoom = true
                }
            }
        })
    }

    func removeScrollViewObservers() {
        scrollViewObservers.removeAll()
    }

    func updateObjectToolbar() {
        guard let selectedObject = selectedObject else { return }

        for item in (objectToolbar.descriptibleItems.compactMap { $0 as? ObjectToolbarItem }) {
            switch item.type {
            case .resetTransform:
                objectToolbar.setEnabled(item: item, enabled: selectedObject.transform != .identity)
            case .sendBack:
                objectToolbar.setEnabled(item: item, enabled: selectedObject.group?.canMoveBack(node: selectedObject) ?? false)
            case .sendForward:
                objectToolbar.setEnabled(item: item, enabled: selectedObject.group?.canMoveForward(node: selectedObject) ?? false)
            default:
                break
            }
        }
    }

    func selectModule(_ module: EditorModule, renderNode: RenderNode?) {
        selectedObject = nil
        delegate?.overviewSelectedModule(module: module, renderNode: renderNode)
    }

    func notifyChange() {
        updateObjectToolbar()
        delegate?.overviewCommittedChange()
    }
}

extension OverviewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard customRecognizers.contains(gestureRecognizer) else { return true }
        guard let objectSelectionView = objectSelectionView else { return false }

        let hitPoint = touch.location(in: objectSelectionView)
        let dragHandle = objectSelectionView.dragHandle(at: hitPoint)

        objectDragger.handle = dragHandle

        return dragHandle != .none
    }
}

// MARK: - ObjectPanHandlerDelegate Conformance

extension OverviewController: ObjectPanHandlerDelegate {
    func objectPanHandlerMoved(handler: ObjectPanHandler, position: CGPoint, delta: CGPoint, finished: Bool) {
        guard let selectedObject = selectedObject else { return }

        objectDragger.object = selectedObject
        objectDragger.drag(position: position, delta: delta, finished: finished)

        if finished {
            delegate?.overviewCommittedChange()
            updateObjectToolbar()
        }

        updateObjectSelectionView()
    }
}

// MARK: - StandardToolbarDelegate Conformance

extension OverviewController: StandardToolbarDelegate {
    func toolbarItemSelected(toolbar: StandardToolbar, item: DescriptibleEditorItem, control: UIControl) {
        switch toolbar {
        case modulesToolbar:
            selectModule(module.modules[control.tag], renderNode: nil)
        case objectToolbar:
            guard let selectedObject = selectedObject else { return }

            switch (item as? ObjectToolbarItem)?.type {
            case .edit:
                guard let module = self.module(for: selectedObject) else { return }
                selectModule(module, renderNode: selectedObject)
            case .delete:
                self.selectedObject = nil
                selectedObject.group?.remove(node: selectedObject)
                notifyChange()
            case .resetTransform:
                selectedObject.transform = .identity
                updateObjectSelectionView()
                notifyChange()
            case .sendBack:
                selectedObject.group?.moveBack(node: selectedObject)
                notifyChange()
            case .sendForward:
                selectedObject.group?.moveForward(node: selectedObject)
                notifyChange()
            default:
                break
            }
        default:
            break
        }
    }
}
