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
        setupModules()
        setupImageView()
        connectViews()
        modulesToolbar.delegate = self
    }
}

private extension OverviewViewController {
    func setupImageView() {
        imageView.isOpaque = false
        imageView.contentMode = .redraw
    }

    func connectViews() {
        view.addSubview(scrollView)
        view.sendSubviewToBack(scrollView)

        modulesToolbar.backgroundColor = Constants.backgroundColor

        setupModulesToolbarConstraints()
        setupScrollViewConstraints()
    }

    func setupModules() {
        var moduleItems = [UIView]()

        for (idx, module) in modules.enumerated() {
            guard let icon = module.icon else { continue }

            let item = modulesToolbar.moduleButton(using: icon, titled: module.title)

            item.tag = idx
            item.tintColor = .white

            moduleItems.append(item)
        }

        modulesToolbar.innerInset = 0
        modulesToolbar.setItems(moduleItems)
    }

    func setupModulesToolbarConstraints() {
        var constraints = [NSLayoutConstraint]()

        constraints.append(contentsOf: view.fill(with: modulesToolbar, connectingEdges: [.left, .right, .bottom]))
        constraints.append(modulesToolbar.heightAnchor.constraint(equalToConstant: Constants.toolbarSize.height))

        for constraint in constraints {
            constraint.isActive = true
        }
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
