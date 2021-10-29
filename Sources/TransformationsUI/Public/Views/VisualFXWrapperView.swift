//
//  VisualFXWrapperView.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 26/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import SnapKit

public class VisualFXWrapperView: UIVisualEffectView {
    private let view: UIView

    public override var intrinsicContentSize: CGSize { view.intrinsicContentSize }

    public init(wrapping view: UIView, usingBlurEffect effect: UIBlurEffect) {
        self.view = view

        super.init(effect: effect)

        let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: effect))

        contentView.addSubview(vibrancyView)
        contentView.addSubview(view)

        vibrancyView.snp.makeConstraints { $0.edges.equalTo(contentView) }
        view.snp.makeConstraints { $0.edges.equalTo(contentView) }

        translatesAutoresizingMaskIntoConstraints = false
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
