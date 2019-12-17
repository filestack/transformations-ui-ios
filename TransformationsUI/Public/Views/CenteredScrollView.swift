//
//  CenteredScrollView.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 14/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public class CenteredScrollView: UIScrollView {
    // MARK: - Misc Overrides

    public override func layoutSubviews() {
        super.layoutSubviews()

        // Keep content centered by default
        keepContentCentered()
    }
}

private extension CenteredScrollView {
    func keepContentCentered() {
        let offsetX = max((bounds.width - contentSize.width) * 0.5, 0)
        let offsetY = max((bounds.height - contentSize.height) * 0.5, 0)

        contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
}
