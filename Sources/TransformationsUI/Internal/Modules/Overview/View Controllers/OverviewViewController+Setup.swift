//
//  OverviewViewController+Setup.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

extension OverviewViewController {
    func setupView() {
        connectViews()
        modulesToolbar.delegate = self
    }
}

private extension OverviewViewController {
    func connectViews() {
        view.addSubview(scrollView)
        view.sendSubviewToBack(scrollView)

        setupModulesToolbarConstraints()
        setupScrollViewConstraints()
    }

    func setupModulesToolbarConstraints() {
        view.fill(with: modulesToolbar, connectingEdges: [.left, .right, .bottom], activate: true)
    }

    func setupScrollViewConstraints() {
        scrollView.addSubview(imageView)

        var constraints = [NSLayoutConstraint]()

        constraints.append(contentsOf: view.fill(with: scrollView, connectingEdges: [.top, .left, .right]))
        constraints.append(scrollView.bottomAnchor.constraint(equalTo: modulesToolbar.topAnchor))

        for constraint in constraints {
            constraint.isActive = true
        }
    }
}
