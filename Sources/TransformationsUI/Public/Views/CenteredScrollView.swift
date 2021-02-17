//
//  CenteredScrollView.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 14/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public class CenteredScrollView: UIScrollView {
    /// Allows adding extra insets to the auto managed `contentInset`.
    public var extraContentInset: UIEdgeInsets = .zero {
        didSet {
            contentInset = contentInset.adding(insets: extraContentInset)
            layoutIfNeeded()
        }
    }

    // MARK: - Misc Overrides

    public override func layoutSubviews() {
        super.layoutSubviews()

        // Keep content centered by default
        keepContentCentered()
    }
}

private extension CenteredScrollView {
    func keepContentCentered() {
        let offsetInsets = UIEdgeInsets(top: max((bounds.height - contentSize.height) * 0.5, 0),
                                        left: max((bounds.width - contentSize.width) * 0.5, 0),
                                        bottom: 0,
                                        right: 0)

        contentInset = offsetInsets.adding(insets: extraContentInset)
    }
}
