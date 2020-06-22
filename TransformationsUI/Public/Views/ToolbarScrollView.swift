//
//  ToolbarScrollView.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 07/12/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public class ToolbarScrollView: CenteredScrollView {
    // MARK: - Lifecycle

    public init() {
        super.init(frame: .zero)

        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        delaysContentTouches = false
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override Functions

    public override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
}
