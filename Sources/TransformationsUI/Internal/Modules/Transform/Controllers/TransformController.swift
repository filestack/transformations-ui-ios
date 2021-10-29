//
//  TransformController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 05/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import AVFoundation.AVUtilities
import UberSegmentedControl
import SwiftMessages

class TransformController: EditorModuleController {
    typealias Module = Modules.Transform

    enum EditMode: Hashable {
        case none
        case crop(mode: Module.Commands.Crop)
    }

    // MARK: - Internal Properties

    let module: Module
    let renderNode: TransformRenderNode
    let viewSource: ModuleViewSource

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

    var hasResizeCommand: Bool {
        return module.extraCommands.contains { $0 is Module.Commands.Resize }
    }

    lazy var cropHandler = RectCropGesturesHandler(delegate: self, allowDraggingFromSides: false)
    lazy var circleHandler = CircleCropGesturesHandler(delegate: self)

    // MARK: - Private Properties

    private var isEditing: Bool = false

    private var extraToolbarCommands: [EditorModuleCommand] {
        module.extraCommands.filter { !($0 is Module.Commands.Resize) }
    }

    private var cropToolbarCommands: [EditorModuleCommand] {
        module.cropCommands
    }

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()

        recognizer.addTarget(self, action: #selector(handlePanGesture(recognizer:)))

        return recognizer
    }()

    private lazy var extraToolbar: StandardToolbar = {
        let toolbar = StandardToolbar(items: extraToolbarCommands, style: .commands)
        toolbar.delegate = self
        toolbar.backgroundColor = Constants.Color.secondaryBackground

        return toolbar
    }()

    private lazy var cropToolbar: SegmentedControlToolbar = {
        let toolbar = SegmentedControlToolbar(items: cropToolbarCommands, style: .segments)

        toolbar.delegate = self
        toolbar.backgroundColor = Constants.Color.secondaryBackground

        return toolbar
    }()

    private var observers: [NSKeyValueObservation] = []

    private let cropLayer = RectCropLayer()
    private let circleLayer = CircleCropLayer()

    private lazy var resizeButton: UIButton = {
        let button = UIButton(type: .system)

        button.tintColor = Constants.Color.defaultTint
        button.titleLabel?.font = Constants.Fonts.default(ofSize: 16)
        button.setImage(UIImage.fromBundle("icon-drop-down-arrow"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets.left = 14
        button.setTitle(resizeButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(resizeTapped), for: .touchUpInside)

        return button
    }()

    private var resizeButtonTitle: String {
        return "\(Int(imageSize.width)) x \(Int(imageSize.height))"
    }

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

    // MARK: - Actions

    @objc func resizeTapped(sender: UIButton) {
        guard let sourceVC = viewSource as? UIViewController else { return }

        let resizeVC = ResizeViewController()

        resizeVC.delegate = self
        resizeVC.imageSize = renderNode.outputImage.extent.size

        let segue = SwiftMessagesCenteredSegue(identifier: nil, source: sourceVC, destination: resizeVC)

        segue.keyboardTrackingView = KeyboardTrackingView()
        segue.perform()
    }

    // MARK: - Pan Gesture Handling

    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        switch editMode {
        case .crop(let mode):
            switch mode.type {
            case .none: break
            case .rect: cropHandler.handlePanGesture(recognizer: recognizer, in: viewSource.scrollView)
            case .circle: circleHandler.handlePanGesture(recognizer: recognizer, in: viewSource.scrollView)
            }
        case .none:
            break
        }
    }
}

// MARK: - Private Functions

private extension TransformController {
    func setup() {
        viewSource.stackView.insertArrangedSubview(extraToolbar, at: 0)
        viewSource.stackView.addArrangedSubview(cropToolbar)
        viewSource.contentView.directionalLayoutMargins = Constants.Spacing.insetContentLayout
        addObservers()
    }

    func cleanup() {
        extraToolbar.removeFromSuperview()
        cropToolbar.removeFromSuperview()
        viewSource.contentView.directionalLayoutMargins = .zero
        editMode = .none
        removeObservers()
    }

    func addObservers() {
        observers.append(imageView.observe(\.image, options: [.new, .old]) { _, change in
            DispatchQueue.main.async {
                self.updateTitle()
            }
        })
    }

    func removeObservers() {
        observers.removeAll()
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
                switch mode.aspectRatio {
                case .free:
                    cropHandler.aspectRatio = imageSize
                    cropHandler.keepAspectRatio = false
                case .original:
                    cropHandler.aspectRatio = imageSize
                    cropHandler.keepAspectRatio = true
                case let .custom(ratio):
                    cropHandler.aspectRatio = ratio
                    cropHandler.keepAspectRatio = true
                }

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
        cropLayer.imageFrame = imageFrame.scaled(by: zoomScale).rounded(originRule: .down, sizeRule: .up)
        cropLayer.cropRect = cropHandler.croppedRect.rounded()
    }

    func updateCircleCropPaths() {
        circleLayer.imageFrame = imageFrame.scaled(by: zoomScale).rounded(originRule: .down, sizeRule: .up)
        circleLayer.circleCenter = circleHandler.circleCenter
        circleLayer.circleRadius = circleHandler.circleRadius
    }

    func addCropGestureRecognizers() {
        viewSource.contentView.addGestureRecognizer(panGestureRecognizer)
    }

    func removeCropGestoreRecognizers() {
        viewSource.contentView.removeGestureRecognizer(panGestureRecognizer)
    }

    func updateTitle() {
        if hasResizeCommand {
            resizeButton.setTitle(resizeButtonTitle, for: .normal)
        }
    }
}

// MARK: - EditorModuleController Conformance

extension TransformController {
    func getModule() -> EditorModule? { module }
    func getRenderNode() -> RenderNode? { renderNode }
    func getTitleView() -> UIView? { hasResizeCommand ? resizeButton : nil }
    func editorDidRestoreSnapshot() { editMode = .none }

    func viewSourceDidLayoutSubviews() {
        DispatchQueue.main.async() {
            self.updatePaths()
        }
    }

    func viewSourceTraitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cropLayer.updateColors()
        circleLayer.updateColors()
    }
}

// MARK: - Editable Conformance

extension TransformController: Editable {
    func applyEditing() {
        applyPendingChanges()
        editMode = .none
        removeObservers()
    }

    func cancelEditing() {
        editMode = .none
        removeObservers()
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
