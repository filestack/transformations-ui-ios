//
//  ObjectRenderNode+Setup.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 25/10/21.
//  Copyright © 2021 Filestack. All rights reserved.
//

import UIKit

extension ObjectRenderNode {
    func center(for size: CGSize) {
        if size.width >= size.height {
            let ratio = size.height / size.width
            bounds.size.height = suggestedSizeInGroup.height * ratio
            bounds.size.width = bounds.size.height / ratio
        } else {
            let ratio = size.width / size.height
            bounds.size.width = suggestedSizeInGroup.width * ratio
            bounds.size.height = bounds.size.width / ratio
        }

        if let groupView = (group as? ViewableNode)?.view {
            center = CGPoint(x: groupView.bounds.midX, y: groupView.bounds.midY)
        }
    }
}
