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
            bounds.size.height *= size.height / size.width
        } else {
            bounds.size.width *= size.width / size.height
        }

        if let groupView = (group as? ViewableNode)?.view {
            center = CGPoint(x: groupView.bounds.midX, y: groupView.bounds.midY)
        }
    }
}
