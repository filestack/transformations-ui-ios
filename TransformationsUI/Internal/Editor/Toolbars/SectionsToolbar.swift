//
//  SectionsToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 30/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

class SectionsToolbar: EditorToolbar {
    var sectionItems: [UIBarButtonItem] = [] {
        didSet { setupItems() }
    }

    init() {
        super.init(frame: .infinite)
        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupItems() {
        setItems([cancel, space] + sectionItems + [space, done], animated: false)
    }
}

private extension SectionsToolbar {
    func setupView() {
        setupItems()
        barTintColor = .black
        backgroundColor = UIColor(white: 31 / 255, alpha: 1)
    }
}
