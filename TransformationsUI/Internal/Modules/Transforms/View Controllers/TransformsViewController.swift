//
//  TransformsViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

class TransformsViewController: ArrangeableViewController, EditorModuleVC, Editable, UIGestureRecognizerDelegate {
    typealias Config = StandardModules.Transforms
    let config: Config

    let preview = UIView()

    enum EditMode: Hashable {
        case crop(mode: Config.Commands.Crop)
        case none
    }

    lazy var imageView: CIImageView = buildImageView()

    lazy var renderNode: RenderNode = {
        let node = TransformsRenderNode()
        node.delegate = self

        return node
    }()

    var editMode = EditMode.none {
        didSet {
            isEditing = editMode == .none ? false : true
            turnOff(mode: oldValue)
            turnOn(mode: editMode)
            updatePaths()
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
}

extension TransformsViewController {
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
        return imageView.layer.sublayers?.contains(layer) ?? false
    }

    func addLayer(for mode: EditMode) {
        guard let editLayer = layer(for: mode), !isVisible(layer: editLayer) else { return }
        imageView.layer.addSublayer(editLayer)
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
        cropLayer.imageFrame = imageFrame
        cropLayer.cropRect = cropHandler.croppedRect
    }

    func updateCirclePaths() {
        circleLayer.imageFrame = imageFrame
        circleLayer.circleCenter = circleHandler.circleCenter
        circleLayer.circleRadius = circleHandler.circleRadius
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

// MARK: - RenderNodeDelegate

extension TransformsViewController: RenderNodeDelegate {
    func renderNodeOutputChanged(renderNode: RenderNode) {
        imageView.image = renderNode.outputImage
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
