//
//  TransformsViewController+ViewSetup.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension TransformsViewController {
    func setupGestureRecognizer() {
        panGestureRecognizer.delegate = self
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(recognizer:)))
        pinchGestureRecognizer.delegate = self
        pinchGestureRecognizer.addTarget(self, action: #selector(handlePinchGesture(recognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(panGestureRecognizer)
        imageView.addGestureRecognizer(pinchGestureRecognizer)
    }

    func setupView() {
        view.backgroundColor = backgroundColor
        toolbar.editorDelegate = self
        setupImageView()
        setupPreview()
        connectViews()
    }

    // MARK: - Private Functions & Properties

    private var backgroundColor: UIColor {
        return UIColor(white: 31 / 255, alpha: 1)
    }

    private func setupImageView() {
        imageView.isOpaque = false
        imageView.contentMode = .redraw
        preview.addSubview(imageClearBackground)
        imageClearBackground.backgroundColor = UIColor(patternImage: .fromFilestackBundle("clear-pattern"))
        imageClearBackground.frame = imageFrame.applying(CGAffineTransform(translationX: 4, y: 4))
    }

    private func setupPreview() {
        preview.backgroundColor = backgroundColor
    }

    private func connectViews() {
        connectBottomToolbar()
        connectPreview()
    }

    private func connectBottomToolbar() {
        view.fill(with: toolbar, connectingEdges: [.bottom], withSafeAreaRespecting: true)
        view.fill(with: toolbar, connectingEdges: [.left, .right], withSafeAreaRespecting: false)
        toolbar.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    private func connectPreview() {
        preview.fill(with: imageView, inset: 4)
        view.fill(with: preview, connectingEdges: [.top, .left, .right], withSafeAreaRespecting: true)
        preview.bottomAnchor.constraint(equalTo: toolbar.topAnchor).isActive = true
    }
}
