//
//  TitledImageButton.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 22/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

/// A `TitledImageButton` displays an image with a label underneath.
public class TitledImageButton: ToolbarButton {
    public var spacing: CGFloat = 5

    // MARK: - Property Overrides

    public override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)
        let imageRect = imageRectUsing(titleRect: rect, forContentRect: contentRect)

        return CGRect(x: 0,
                      y: imageRect.maxY + spacing,
                      width: contentRect.width,
                      height: rect.height)
    }

    public override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleRect = self.titleRect(forContentRect: contentRect)

        return imageRectUsing(titleRect: titleRect, forContentRect: contentRect)
    }

    public override var intrinsicContentSize: CGSize {
        return bounds.size
    }

    // MARK: - Lifecycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        centerTitleLabel()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerTitleLabel()
    }
}

// MARK: - Private Functions

private extension TitledImageButton {
    func imageRectUsing(titleRect: CGRect, forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.imageRect(forContentRect: contentRect)

        return CGRect(x: contentRect.width / 2.0 - rect.width / 2.0,
                      y: max(0, (contentRect.height - rect.height - titleRect.height - spacing) / 2.0),
                      width: rect.width,
                      height: rect.height)
    }

    func centerTitleLabel() {
        titleLabel?.textAlignment = .center
    }
}
