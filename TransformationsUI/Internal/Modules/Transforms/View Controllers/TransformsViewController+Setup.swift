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
    }

    func setupView() {
        toolbar.delegate = self
        setupImageView()
        setupScrollView()
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
        view.addSubview(scrollView)
        view.sendSubviewToBack(scrollView)

        setupToolbar()
        setupScrollView()
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

    func setupScrollView() {
        scrollView.addSubview(imageView)

        // On .. x hR
        defineConstraints(width: .unspecified, height: .regular) {
            var constraints = [NSLayoutConstraint]()

            constraints.append(contentsOf: view.fill(with: scrollView, connectingEdges: [.left, .right, .top]))
            constraints.append(scrollView.bottomAnchor.constraint(equalTo: toolbar.topAnchor))

            return constraints
        }

        // On .. x hC
        defineConstraints(width: .unspecified, height: .compact) {
            var constraints = [NSLayoutConstraint]()

            constraints.append(contentsOf: view.fill(with: scrollView, connectingEdges: [.top, .bottom, .left]))
            constraints.append(scrollView.rightAnchor.constraint(equalTo: toolbar.leftAnchor))

            return constraints
        }
    }
}
