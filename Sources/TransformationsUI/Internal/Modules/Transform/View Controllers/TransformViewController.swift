//
//  TransformViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

class TransformViewController: ModuleViewController {
    typealias Module = StandardModules.Transform

    enum EditMode: Hashable {
        case none
        case crop(mode: Module.Commands.Crop)
    }

    // MARK: - Internal Properties
    
    let module: Module
    lazy var renderNode = TransformRenderNode()

    var editMode = EditMode.none {
        didSet {
            isEditing = editMode != .none
            turnOff(mode: oldValue)
            turnOn(mode: editMode)
            updatePaths()

            if isEditing {
                canScrollAndZoom = false
                addCropGestureRecognizers()
            } else {
                canScrollAndZoom = true
                removeCropGestoreRecognizers()
                cropToolbar.resetSelectedSegment()
            }
        }
    }

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()

        recognizer.addTarget(self, action: #selector(handlePanGesture(recognizer:)))

        return recognizer
    }()

    var extraToolbarCommands: [EditorModuleCommand] { module.extraCommands }
    var cropToolbarCommands: [EditorModuleCommand] { module.cropCommands }

    lazy var extraToolbar: StandardToolbar = {
        let toolbar = StandardToolbar(items: extraToolbarCommands, style: .commands)
        toolbar.delegate = self

        return toolbar
    }()

    lazy var cropToolbar: SegmentedControlToolbar = {
        let toolbar = SegmentedControlToolbar(items: cropToolbarCommands, style: .segments)

        toolbar.delegate = self

        return toolbar
    }()

    lazy var cropHandler = RectCropGesturesHandler(delegate: self, allowDraggingFromSides: false)
    lazy var circleHandler = CircleCropGesturesHandler(delegate: self)

    // MARK: - Private Properties

    private let cropLayer = RectCropLayer()
    private let circleLayer = CircleCropLayer()

    // MARK: - View Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        DispatchQueue.main.async() {
            self.updatePaths()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cropLayer.updateColors()
        circleLayer.updateColors()
    }

    // MARK: - Lifecycle

    required init(module: Module) {
        self.module = module
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Pan Gesture Handling

    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        switch editMode {
        case .crop(let mode):
            switch mode.type {
            case .none: break
            case .rect: cropHandler.handlePanGesture(recognizer: recognizer, in: scrollView)
            case .circle: circleHandler.handlePanGesture(recognizer: recognizer, in: scrollView)
            }
        case .none:
            break
        }
    }
}

// MARK: - Private Functions

private extension TransformViewController {
    func setupView() {
        stackView.insertArrangedSubview(extraToolbar, at: 0)
        stackView.addArrangedSubview(cropToolbar)
        contentView.directionalLayoutMargins = Constants.Spacing.insetContentLayout
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
                cropHandler.reset()
                circleHandler.reset()
            case .rect:
                cropHandler.reset()
            case .circle:
                circleHandler.reset()
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
            case .rect: return cropLayer
            case .circle: return circleLayer
            }
        case .none:
            return nil
        }
    }

    func isVisible(layer: CALayer) -> Bool {
        return scrollView.layer.sublayers?.contains(layer) ?? false
    }

    func addLayer(for mode: EditMode) {
        guard let editLayer = layer(for: mode), !isVisible(layer: editLayer) else { return }
        scrollView.layer.addSublayer(editLayer)
    }

    func hideLayer(for mode: EditMode) {
        layer(for: mode)?.removeFromSuperlayer()
    }

    func updatePaths() {
        switch editMode {
        case .crop(let mode):
            switch mode.type {
            case .none: break
            case .rect: updateCropPaths()
            case .circle: updateCirclePaths()
            }
        case .none:
            break
        }
    }

    func updateCropPaths() {
        cropLayer.imageFrame = imageFrame.scaled(by: zoomScale).rounded(originRule: .down, sizeRule: .up)
        cropLayer.cropRect = cropHandler.croppedRect.rounded()
    }

    func updateCirclePaths() {
        circleLayer.imageFrame = imageFrame.scaled(by: zoomScale).rounded(originRule: .down, sizeRule: .up)
        circleLayer.circleCenter = circleHandler.circleCenter
        circleLayer.circleRadius = circleHandler.circleRadius
    }

    func addCropGestureRecognizers() {
        contentView.addGestureRecognizer(panGestureRecognizer)
    }

    func removeCropGestoreRecognizers() {
        contentView.removeGestureRecognizer(panGestureRecognizer)
    }
}

// MARK: - EditorModuleVC Protocol

extension TransformViewController: EditorModuleVC {
    func getModule() -> EditorModule? { module }
    func getRenderNode() -> RenderNode { renderNode }
}

// MARK: - Editable Protocol

extension TransformViewController: Editable {
    func applyEditing() {
        applyPendingChanges()
        editMode = .none
    }

    func cancelEditing() {
        editMode = .none
    }
}

// MARK: - RectCropGesturesHandlerDelegate Conformance

extension TransformViewController: RectCropGesturesHandlerDelegate {
    func updateCropInset(_: UIEdgeInsets) {
        updateCropPaths()
    }
}

// MARK: - CircleCropGesturesHandlerDelegate Conformance

extension TransformViewController: CircleCropGesturesHandlerDelegate {
    func updateCircle(_: CGPoint, radius _: CGFloat) {
        updateCirclePaths()
    }
}
