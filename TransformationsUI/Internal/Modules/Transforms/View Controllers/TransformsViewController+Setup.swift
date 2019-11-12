//
//  TransformsViewController+Setup.swift
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
        toolbar.delegate = self
        setupImageView()
        setupPreview()
        connectViews()
    }
}

private extension TransformsViewController {
    func setupImageView() {
        imageView.isOpaque = false
        imageView.contentMode = .redraw
    }

    func connectViews() {
        view.addSubview(toolbar)
        view.addSubview(preview)

        setupToolbar()
        setupPreview()
    }

    func setupToolbar() {
        // On hR — anchor toolbar to the bottom
        defineConstraints(width: .unspecified, height: .regular) {
            var constraints = [NSLayoutConstraint]()

            constraints.append(contentsOf: view.fill(with: toolbar, connectingEdges: [.left, .right, .bottom]))
            constraints.append(toolbar.heightAnchor.constraint(equalToConstant: Constants.toolbarSize))

            return constraints
        }

        // On hC — anchor toolbar to the right
        defineConstraints(width: .unspecified, height: .compact) {
            var constraints = [NSLayoutConstraint]()

            constraints.append(contentsOf: view.fill(with: toolbar, connectingEdges: [.top, .right, .bottom]))
            constraints.append(toolbar.widthAnchor.constraint(equalToConstant: Constants.toolbarSize))

            return constraints
        }
    }

    func setupPreview() {
        preview.fill(with: imageView, inset: 4, activate: true)

        // On .. x hR
        defineConstraints(width: .unspecified, height: .regular) {
            var constraints = [NSLayoutConstraint]()

            constraints.append(contentsOf: view.fill(with: preview, connectingEdges: [.left, .right]))
            constraints.append(contentsOf: view.fill(with: preview, connectingEdges: [.top]))

            let bottomConstraint = preview.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
            constraints.append(bottomConstraint)

            return constraints
        }

        // On .. x hC
        defineConstraints(width: .unspecified, height: .compact) {
            var constraints = [NSLayoutConstraint]()

            constraints.append(contentsOf: view.fill(with: preview, connectingEdges: [.top, .bottom]))
            constraints.append(contentsOf: view.fill(with: preview, connectingEdges: [.left], inset: Constants.toolbarSize))

            let rightConstraint = preview.rightAnchor.constraint(equalTo: toolbar.leftAnchor)
            constraints.append(rightConstraint)

            return constraints
        }
    }
}
