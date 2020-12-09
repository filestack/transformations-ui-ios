//
//  TransformViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

class TransformController: EditorModuleController {
    typealias Module = StandardModules.Transform

    enum EditMode: Hashable {
        case none
        case crop(mode: Module.Commands.Crop)
    }

    // MARK: - Internal Properties
    
    let module: Module
    let renderNode: TransformRenderNode

    var isEditing: Bool = false

    var editMode = EditMode.none {
        didSet {
            isEditing = editMode != .none
            turnOff(mode: oldValue)
            turnOn(mode: editMode)
            updatePaths()

            if isEditing {
                viewSource.canScrollAndZoom = false
                addCropGestureRecognizers()
            } else {
                viewSource.canScrollAndZoom = true
                removeCropGestoreRecognizers()
                cropToolbar.resetSelectedSegment()
            }
        }
    }

    let viewSource: ModuleViewSource

    lazy var rectCropHandler = RectCropGesturesHandler(delegate: self, allowDraggingFromSides: false)
    lazy var circleCropHandler = CircleCropGesturesHandler(delegate: self)

    // MARK: - Private Properties

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()

        recognizer.addTarget(self, action: #selector(handlePanGesture(recognizer:)))

        return recognizer
    }()

    private var extraToolbarCommands: [EditorModuleCommand] { module.extraCommands }
    private var cropToolbarCommands: [EditorModuleCommand] { module.cropCommands }

    private lazy var extraToolbar: StandardToolbar = {
        let toolbar = StandardToolbar(items: extraToolbarCommands, style: .commands)
        toolbar.delegate = self

        return toolbar
    }()

    private lazy var cropToolbar: SegmentedControlToolbar = {
        let toolbar = SegmentedControlToolbar(items: cropToolbarCommands, style: .segments)

        toolbar.delegate = self

        return toolbar
    }()

    private lazy var extraToolbarFXWrapperView: UIView = {
        VisualFXWrapperView(wrapping: extraToolbar, usingBlurEffect: Constants.ViewEffects.blur)
    }()

    private lazy var cropToolbarFXWrapperView: UIView = {
        VisualFXWrapperView(wrapping: cropToolbar, usingBlurEffect: Constants.ViewEffects.blur)
    }()

    private let rectCropLayer = RectCropLayer()
    private let circleCropLayer = CircleCropLayer()

    // MARK: - View Overrides

    func viewSourceDidLayoutSubviews() {
        DispatchQueue.main.async() {
            self.updatePaths()
        }
    }

    func viewSourceTraitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        rectCropLayer.updateColors()
        circleCropLayer.updateColors()
    }

    func getModule() -> EditorModule? { module }
    func getRenderNode() -> RenderNode? { renderNode }
    func editorDidRestoreSnapshot() { editMode = .none }

    // MARK: - Lifecycle

    required init(renderNode: RenderNode?, module: EditorModule, viewSource: ModuleViewSource) {
        self.module = module as! Module
        self.renderNode = renderNode as! TransformRenderNode
        self.viewSource = viewSource
        setup()
    }

    deinit {
        cleanup()
    }

    // MARK: - Pan Gesture Handling

    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        switch editMode {
        case .crop(let mode):
            switch mode.type {
            case .none: break
            case .rect: rectCropHandler.handlePanGesture(recognizer: recognizer, in: viewSource.scrollView)
            case .circle: circleCropHandler.handlePanGesture(recognizer: recognizer, in: viewSource.scrollView)
            }
        case .none:
            break
        }
    }
}

// MARK: - Private Functions

private extension TransformController {
    func setup() {
        viewSource.stackView.insertArrangedSubview(extraToolbarFXWrapperView, at: 0)
        viewSource.stackView.addArrangedSubview(cropToolbarFXWrapperView)
        viewSource.contentView.directionalLayoutMargins = Constants.Spacing.insetContentLayout
    }

    func cleanup() {
        extraToolbarFXWrapperView.removeFromSuperview()
        cropToolbarFXWrapperView.removeFromSuperview()
        viewSource.contentView.directionalLayoutMargins = .zero
        editMode = .none
    }

    func turnOff(mode: EditMode) {
        hideLayer(for: mode)
    }

    func turnOn(mode: EditMode) {
        addLayer(for: mode)

        switch mode {
        case .crop(let mode):
            switch mode.type {
            case .none:
                rectCropHandler.reset()
                circleCropHandler.reset()
            case .rect:
                rectCropHandler.reset()
            case .circle:
                circleCropHandler.reset()
            }
        case .none:
            break
        }
    }

    func layer(for mode: EditMode) -> CALayer? {
        switch mode {
        case .crop(let mode):
            switch mode.type {
            case .none: return nil
            case .rect: return rectCropLayer
            case .circle: return circleCropLayer
            }
        case .none:
            return nil
        }
    }

    func isVisible(layer: CALayer) -> Bool {
        return viewSource.scrollView.layer.sublayers?.contains(layer) ?? false
    }

    func addLayer(for mode: EditMode) {
        guard let editLayer = layer(for: mode), !isVisible(layer: editLayer) else { return }
        viewSource.scrollView.layer.addSublayer(editLayer)
    }

    func hideLayer(for mode: EditMode) {
        layer(for: mode)?.removeFromSuperlayer()
    }

    func updatePaths() {
        switch editMode {
        case .crop(let mode):
            switch mode.type {
            case .none: break
            case .rect: updateRectCropPaths()
            case .circle: updateCircleCropPaths()
            }
        case .none:
            break
        }
    }

    func updateRectCropPaths() {
        rectCropLayer.imageFrame = imageFrame.scaled(by: zoomScale).rounded(originRule: .down, sizeRule: .up)
        rectCropLayer.cropRect = rectCropHandler.croppedRect.rounded()
    }

    func updateCircleCropPaths() {
        circleCropLayer.imageFrame = imageFrame.scaled(by: zoomScale).rounded(originRule: .down, sizeRule: .up)
        circleCropLayer.circleCenter = circleCropHandler.circleCenter
        circleCropLayer.circleRadius = circleCropHandler.circleRadius
    }

    func addCropGestureRecognizers() {
        viewSource.contentView.addGestureRecognizer(panGestureRecognizer)
    }

    func removeCropGestoreRecognizers() {
        viewSource.contentView.removeGestureRecognizer(panGestureRecognizer)
    }
}

// MARK: - Editable Protocol

extension TransformController: Editable {
    func applyEditing() {
        applyPendingChanges()
        editMode = .none
    }

    func cancelEditing() {
        editMode = .none
    }
}

// MARK: - RectCropGesturesHandlerDelegate Conformance

extension TransformController: RectCropGesturesHandlerDelegate {
    func rectCropChanged(_ handler: RectCropGesturesHandler) {
        updateRectCropPaths()
    }
}

// MARK: - CircleCropGesturesHandlerDelegate Conformance

extension TransformController: CircleCropGesturesHandlerDelegate {
    func circleCropChanged(_ handler: CircleCropGesturesHandler) {
        updateCircleCropPaths()
    }
}
