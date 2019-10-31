//
//  TransformsViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public class TransformsViewController: UIViewController, UIGestureRecognizerDelegate, Section {
    public lazy var icon = UIImage.fromFilestackBundle("icon-section-transforms")

    public lazy var renderNode: RenderNode = {
        let node = TransformsRenderNode()
        node.delegate = self

        return node
    }()

    enum EditMode {
        case crop, circle, none
    }

    var editMode = EditMode.none {
        didSet {
            turnOff(mode: oldValue)
            turnOn(mode: editMode)
            updatePaths()
        }
    }

    let toolbar = TransformsToolbar()
    let preview = UIView()
    let imageView = MetalImageView()
    let imageClearBackground = UIView()

    var panGestureRecognizer = UIPanGestureRecognizer()
    var pinchGestureRecognizer = UIPinchGestureRecognizer()

    lazy var cropHandler = CropGesturesHandler(delegate: self)
    lazy var circleHandler = CircleGesturesHandler(delegate: self)

    private let cropLayer = CropLayer()
    private let circleLayer = CircleLayer()

    // MARK: - Lifecycle Functions

    init() {
        super.init(nibName: nil, bundle: nil)

        title = "Transforms"
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View overrides

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupGestureRecognizer()
        setupView()
    }
}

extension TransformsViewController {
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        DispatchQueue.main.async() {
            self.updatePaths()
            self.imageClearBackground.frame = self.imageFrame.applying(CGAffineTransform(translationX: 4, y: 4))
        }
    }
}

private extension TransformsViewController {
    func turnOff(mode: EditMode) {
        hideLayer(for: mode)
    }

    func turnOn(mode: EditMode) {
        addLayer(for: mode)
        toolbar.isEditing = (mode != .none)
    }
}

private extension TransformsViewController {
    func layer(for mode: EditMode) -> CALayer? {
        switch mode {
        case .crop: return cropLayer
        case .circle: return circleLayer
        case .none: return nil
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
        case .crop: updateCropPaths()
        case .circle: updateCirclePaths()
        case .none: return
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
        case .crop: cropHandler.handlePanGesture(recognizer: recognizer)
        case .circle: circleHandler.handlePanGesture(recognizer: recognizer)
        case .none: return
        }
    }

    @objc func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
        switch editMode {
        case .crop: return
        case .circle: circleHandler.handlePinchGesture(recognizer: recognizer)
        case .none: return
        }
    }
}

// MARK: - RenderNodeDelegate

extension TransformsViewController: RenderNodeDelegate {
    public func renderNodeOutputChanged(renderNode: RenderNode) {
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
