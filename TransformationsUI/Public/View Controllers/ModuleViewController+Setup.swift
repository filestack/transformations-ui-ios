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
        scrollView.addSubview(imageView)

        scrollWrapperView.addSubview(scrollView)
        scrollWrapperView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        scrollWrapperView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        scrollWrapperView.layoutMarginsGuide.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        scrollWrapperView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true

        stackView.addArrangedSubview(scrollWrapperView)

        if let discardApplyToolbar = discardApplyToolbar {
            stackView.addArrangedSubview(discardApplyToolbar)

            discardApplyToolbar.backgroundColor = Constants.Color.background

            var constraints = [NSLayoutConstraint]()

            constraints.append(discardApplyToolbar.heightAnchor.constraint(equalToConstant: Constants.Size.toolbar.height))

            for constraint in constraints {
                constraint.isActive = true
            }
        }

        view.fill(with: stackView, activate: true)
    }
}
