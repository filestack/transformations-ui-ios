//
//  RenderGroupChildNode+SuggestedSize.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 3/11/21.
//  Copyright © 2021 Filestack. All rights reserved.
//

import UIKit

extension RenderGroupChildNode {
    var suggestedSizeInGroup: CGSize {
        guard let groupView = (group as? ViewableNode)?.view else { return .zero }

        let bounds = groupView.bounds
        let size: CGFloat = min(bounds.width, bounds.height) * 0.90

        return CGSize(width: size, height: size)
    }
}
