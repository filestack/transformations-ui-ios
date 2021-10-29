//
//  OverviewViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

protocol OverviewControllerDelegate: AnyObject {
    func overviewSelectedModule(module: EditorModule, renderNode: RenderNode?)
    func overviewCommittedChange()
}

class OverviewController: NSObject, EditorModuleController {
    typealias Module = Modules.Overview

    // MARK: - Internal Properties

    weak var delegate: OverviewControllerDelegate?
    let viewSource: ModuleViewSource

    // MARK: - Private Properties

    private let module: Modules.Overview

    private lazy var modulesToolbar: StandardToolbar = {
        let toolbar = StandardToolbar(items: module.modules, style: .modules)

        toolbar.delegate = self

        return toolbar
    }()

    private(set) lazy var objectToolbar: StandardToolbar = {
        let toolbar = StandardToolbar(items: module.commands, style: .commands)

        toolbar.delegate = self
        toolbar.backgroundColor = Constants.Color.secondaryBackground

        return toolbar
    }()

    private(set) var detailToolbar: BoundedRangeCommandToolbar?

    private(set) lazy var objectToolbarStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [objectToolbar])

        stackView.axis = .vertical
        stackView.alpha = 0

        return stackView
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
        didSet { select(object: selectedObject) }
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

    private let objectPanHandler = ObjectPanHandler()
    private let objectDragger = ObjectDragger()

    private var scrollViewObservers: [NSObjectProtocol] = []

    // MARK: - Lifecycle

    required init(renderNode: RenderNode?, module: EditorModule, viewSource: ModuleViewSource) {
        self.module = module as! Modules.Overview
        self.viewSource = viewSource
        self.selectedObject = renderNode as? ObjectRenderNode

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

        updateDetailToolbar()
    }
}

// MARK: - Private Functions

private extension OverviewController {
    func setup() {
        select(object: selectedObject)
        objectPanHandler.delegate = self
        addGestureRecognizers()
        viewSource.stackView.addArrangedSubview(objectToolbarStack)
        viewSource.stackView.addArrangedSubview(modulesToolbar)
    }

    func cleanup() {
        selectedObject = nil
        removeGestureRecognizers()
        removeObjectSelectionView()
        modulesToolbar.removeFromSuperview()
        objectToolbarStack.removeFromSuperview()
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

            objectToolbarStack.alpha = 1
            updateObjectSelectionView()
            updateObjectToolbar()
        } else {
            removeObjectSelectionView()
            objectToolbarStack.alpha = 0
        }

        updateDetailToolbar()
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

        for item in objectToolbar.descriptibleItems {
            switch item {
            case is Module.Commands.Reset:
                objectToolbar.setEnabled(item: item, enabled: selectedObject.transform != .identity)
            case is Module.Commands.Back:
                objectToolbar.setEnabled(item: item, enabled: selectedObject.group?.canMoveBack(node: selectedObject) ?? false)
            case is Module.Commands.Forward:
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

    func setupDetailToolbar(for command: BoundedRangeCommand) {
        if detailToolbar == nil {
            let detailToolbar = BoundedRangeCommandToolbar(command: command, style: .boundedRangeCommand)
            detailToolbar.delegate = self
            self.detailToolbar = detailToolbar
        } else if let detailToolbar = detailToolbar, detailToolbar.command.uuid != command.uuid {
            detailToolbar.command = command
        } else {
            detailToolbar?.removeFromSuperview()
            detailToolbar = nil
        }

        if let detailToolbar = detailToolbar, !objectToolbarStack.arrangedSubviews.contains(detailToolbar) {
            // Add detail toolbar before `detailToolbar`
            if let idx = objectToolbarStack.arrangedSubviews.firstIndex(of: objectToolbar) {
                objectToolbarStack.insertArrangedSubview(detailToolbar, at: idx)
            }
        }

        updateDetailToolbar()
    }

    func updateDetailToolbar() {
        guard let detailToolbar = detailToolbar else { return }
        guard let selectedObject = selectedObject else { return }

        switch detailToolbar.command {
        case is Module.Commands.Opacity:
            detailToolbar.updateValue(value: Double(selectedObject.opacity))
        default:
            break
        }

        viewSource.stackView.setNeedsLayout()
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

            switch item {
            case is Module.Commands.Edit:
                guard let module = self.module(for: selectedObject) else { return }
                selectModule(module, renderNode: selectedObject)
            case is Module.Commands.Delete:
                self.selectedObject = nil
                selectedObject.group?.remove(node: selectedObject)
                notifyChange()
            case is Module.Commands.Reset:
                selectedObject.transform = .identity
                updateObjectSelectionView()
                notifyChange()
            case is Module.Commands.Back:
                selectedObject.group?.moveBack(node: selectedObject)
                notifyChange()
            case is Module.Commands.Forward:
                selectedObject.group?.moveForward(node: selectedObject)
                notifyChange()
            case is Module.Commands.Flip:
                selectedObject.transform = selectedObject.transform.scaledBy(x: -1, y: 1)
                updateObjectSelectionView()
                notifyChange()
            case is Module.Commands.Flop:
                selectedObject.transform = selectedObject.transform.scaledBy(x: 1, y: -1)
                updateObjectSelectionView()
                notifyChange()
            case is Module.Commands.Opacity:
                guard let boundedRangeCommand = item as? BoundedRangeCommand else { return }

                setupDetailToolbar(for: boundedRangeCommand)
            default:
                break
            }
        default:
            break
        }
    }
}

// MARK: - BoundedRangeCommandToolbarDelegate Conformance

extension OverviewController: BoundedRangeCommandToolbarDelegate {
    func toolbarSliderChanged(slider: UISlider, for command: BoundedRangeCommand) {
        guard let selectedObject = selectedObject else { return }

        switch command {
        case is Module.Commands.Opacity:
            selectedObject.opacity = CGFloat(slider.value)
        default:
            break
        }
    }

    func toolbarSliderFinishedChanging(slider: UISlider, for command: BoundedRangeCommand) {
        notifyChange()
    }
}
