//
//  ModuleViewController+Setup.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import SnapKit

extension ModuleViewController {
    func setup() {
        canScrollAndZoom = true

        contentView.addSubview(scrollView)
        stackView.addArrangedSubview(contentView)

        contentView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.layoutMarginsGuide.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true

        view.addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalTo(view) }

        view.clipsToBounds = true
    }
}
