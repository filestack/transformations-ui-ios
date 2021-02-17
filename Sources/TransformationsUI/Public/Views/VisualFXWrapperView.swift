//
//  VisualFXWrapperView.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 26/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

public class VisualFXWrapperView: UIVisualEffectView {
    private let view: UIView

    public override var intrinsicContentSize: CGSize { view.intrinsicContentSize }

    public init(wrapping view: UIView, usingBlurEffect effect: UIBlurEffect) {
        self.view = view

        super.init(effect: effect)

        let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: effect))

        contentView.fill(with: vibrancyView, activate: true)
        contentView.fill(with: view, activate: true)
        translatesAutoresizingMaskIntoConstraints = false
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
