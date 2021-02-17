//
//  StackViewWithIntrinsicHeight.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 27/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

class StackViewWithIntrinsicHeight: UIStackView {
    override var intrinsicContentSize: CGSize {
        let viewHeights = subviews.reduce(0) { $0 + $1.intrinsicContentSize.height }
        let totalSpacing = spacing * CGFloat(subviews.count - 1)

        return CGSize(width: UIView.noIntrinsicMetric, height: viewHeights + totalSpacing)
    }

    override func addArrangedSubview(_ view: UIView) {
        super.addArrangedSubview(view)

        invalidateIntrinsicContentSize()
    }

    override func removeArrangedSubview(_ view: UIView) {
        super.removeArrangedSubview(view)

        invalidateIntrinsicContentSize()
    }
}
