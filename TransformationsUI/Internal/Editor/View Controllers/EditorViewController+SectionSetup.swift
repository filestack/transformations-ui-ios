//
//  EditorViewController+Sections.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension EditorViewController {
    func setupSections() {
        var sectionItems = [UIBarButtonItem]()

        for (idx, section) in sections.enumerated() {
            let item = UIBarButtonItem(image: section.icon,
                                       style: .plain,
                                       target: self,
                                       action: #selector(showSection))

            item.tag = idx
            item.tintColor = .white

            sectionItems.append(item)
        }

        sectionsToolbar.sectionItems = sectionItems

        // Show first section by default.
        if let section = sections.first {
            containerView.fill(with: section.view)
        }
    }

    @objc func showSection(_ sender: UIBarButtonItem) {
        let section = sections[sender.tag]
        containerView.fill(with: section.view)
    }
}
