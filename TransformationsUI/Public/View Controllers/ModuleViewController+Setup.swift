//
//  ModuleViewController+Setup.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

extension ModuleViewController {

    func setup() {
        imageView.isOpaque = false
        imageView.contentMode = .redraw
        addViews()
    }
}

private extension ModuleViewController {
    func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        stackView.addArrangedSubview(scrollView)

        if let discardApplyToolbar = discardApplyToolbar {
            stackView.addArrangedSubview(discardApplyToolbar)

            discardApplyToolbar.backgroundColor = Constants.backgroundColor

            var constraints = [NSLayoutConstraint]()

            constraints.append(discardApplyToolbar.heightAnchor.constraint(equalToConstant: Constants.toolbarSize.height))

            for constraint in constraints {
                constraint.isActive = true
            }
        }

        view.fill(with: stackView, activate: true)
    }
}
