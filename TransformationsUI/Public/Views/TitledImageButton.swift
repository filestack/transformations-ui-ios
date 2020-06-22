//
//  TitledImageButton.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 22/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

/// A `TitledImageButton` displays an image with a label underneath.
class TitledImageButton: UIButton {
    var padding: CGFloat = 5

    // MARK: - Property Overrides

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)
        let imageRect = imageRectUsing(titleRect: rect, forContentRect: contentRect)

        return CGRect(x: 0,
                      y: imageRect.maxY + padding,
                      width: contentRect.width,
                      height: rect.height)
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleRect = self.titleRect(forContentRect: contentRect)

        return imageRectUsing(titleRect: titleRect, forContentRect: contentRect)
    }

    override var intrinsicContentSize: CGSize {
        return bounds.size
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        centerTitleLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerTitleLabel()
    }

    // MARK: - Private Functions

    private func imageRectUsing(titleRect: CGRect, forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.imageRect(forContentRect: contentRect)

        return CGRect(x: contentRect.width / 2.0 - rect.width / 2.0,
                      y: max(0, (contentRect.height - rect.height - titleRect.height - padding) / 2.0),
                      width: rect.width,
                      height: rect.height)
    }

    private func centerTitleLabel() {
        titleLabel?.textAlignment = .center
    }
}

