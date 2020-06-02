//
//  TransformViewController+Setup.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension TransformViewController {
    func setupGestureRecognizer() {
        panGestureRecognizer.delegate = self
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(recognizer:)))
        pinchGestureRecognizer.delegate = self
        pinchGestureRecognizer.addTarget(self, action: #selector(handlePinchGesture(recognizer:)))
    }

    func setupView() {
        extraToolbar.delegate = self
        cropToolbar.delegate = self
        addViews()
    }
}

private extension TransformViewController {
    func addViews() {
        stackView.insertArrangedSubview(extraToolbar, at: 0)
        stackView.insertArrangedSubview(cropToolbar, at: max(0, stackView.arrangedSubviews.count - 1))

        extraToolbar.backgroundColor = Constants.toolbarColor
        cropToolbar.backgroundColor = Constants.toolbarColor

        extraToolbar.innerInset = 0
        cropToolbar.innerInset = 0

        var constraints = [NSLayoutConstraint]()

        constraints.append(extraToolbar.heightAnchor.constraint(equalToConstant: Constants.toolbarSize.height))
        constraints.append(cropToolbar.heightAnchor.constraint(equalToConstant: Constants.toolbarSize.height))

        for constraint in constraints {
            constraint.isActive = true
        }
    }
}
