//
//  TransformsViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

class TransformsViewController: ModuleViewController, EditorModuleVC, Editable, UIGestureRecognizerDelegate {
    typealias Config = StandardModules.Transforms
    let config: Config

    enum EditMode: Hashable {
        case crop(mode: Config.Commands.Crop)
        case none
    }

    lazy var renderNode = TransformsRenderNode()

    var editMode = EditMode.none {
        didSet {
            isEditing = editMode == .none ? false : true
            turnOff(mode: oldValue)
            turnOn(mode: editMode)
            updatePaths()

            if isEditing {
                addCropGestureRecognizers()
            } else {
                removeCropGestoreRecognizers()
            }
        }
    }

    var panGestureRecognizer = UIPanGestureRecognizer()
    var pinchGestureRecognizer = UIPinchGestureRecognizer()

    lazy var toolbar = ModuleToolbar(commands: config.commands)
    lazy var cropHandler = CropGesturesHandler(delegate: self)
    lazy var circleHandler = CircleGesturesHandler(delegate: self)

    private let cropLayer = CropLayer()
    private let circleLayer = CircleLayer()

    // MARK: - Lifecycle Functions

    required init(config: Config) {
        self.config = config

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal Functions

    func getRenderNode() -> RenderNode {
        return renderNode
    }

    func applyEditing() {
        saveSelected()
    }

    func cancelEditing() {
        editMode = .none
    }

    // MARK: - View overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGestureRecognizer()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateImageView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        cancelEditing()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        DispatchQueue.main.async() {
            self.updatePaths()
        }
    }
}

private extension TransformsViewController {
    func turnOff(mode: EditMode) {
        hideLayer(for: mode)
    }

    func turnOn(mode: EditMode) {
        addLayer(for: mode)

        switch mode {
        case .crop(let mode):
            switch mode.type {
            case .rect:
                cropHandler.reset()
            case .circle:
                circleHandler.reset()
            }
        case .none:
            break
        }
    }
}

private extension TransformsViewController {
    func layer(for mode: EditMode) -> CALayer? {
        switch mode {
        case .crop(let mode):
            switch mode.type {
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
        scrollView.addGestureRecognizer(panGestureRecognizer)
        scrollView.addGestureRecognizer(pinchGestureRecognizer)
    }

    func removeCropGestoreRecognizers() {
        scrollView.removeGestureRecognizer(panGestureRecognizer)
        scrollView.removeGestureRecognizer(pinchGestureRecognizer)
    }
}

extension TransformsViewController {
    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        switch editMode {
        case .crop(let mode):
            switch mode.type {
            case .rect: cropHandler.handlePanGesture(recognizer: recognizer)
            case .circle: circleHandler.handlePanGesture(recognizer: recognizer)
            }
        case .none:
            break
        }
    }

    @objc func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
        switch editMode {
        case .crop(let mode):
            switch mode.type {
            case .rect: break
            case .circle: circleHandler.handlePinchGesture(recognizer: recognizer)
            }
        case .none:
            break
        }
    }
}

// MARK: - EditCropDelegate

extension TransformsViewController: EditCropDelegate {
    func updateCropInset(_: UIEdgeInsets) {
        updateCropPaths()
    }
}

// MARK: - EditCircleDelegate

extension TransformsViewController: EditCircleDelegate {
    func updateCircle(_: CGPoint, radius _: CGFloat) {
        updateCirclePaths()
    }
}
