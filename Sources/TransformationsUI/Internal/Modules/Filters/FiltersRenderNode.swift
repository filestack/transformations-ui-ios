//
//  FiltersRenderNode.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 20/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

class FiltersRenderNode: RenderNode, RenderGroupChildNode & IONode {
    weak var group: RenderGroupNode?

    var inputImage: CIImage = CIImage() {
        didSet { applyFilterType() }
    }

    var outputImage: CIImage { renderedImage ?? inputImage }

    var renderedImage: CIImage? = nil {
        didSet { group?.nodeChanged(node: self) }
    }

    var filterType: FilterType = .none {
        didSet { applyFilterType() }
    }

    // MARK: - Private Functions

    private func applyFilterType() {
        renderedImage = inputImage.applying(filterType: filterType)
    }
}

extension FiltersRenderNode: Snapshotable {
    public func snapshot() -> Snapshot {
        return [
            "filterType": filterType
        ]
    }

    public func restore(from snapshot: Snapshot) {
        for item in snapshot {
            switch item {
            case let("filterType", filterType as FilterType):
                self.filterType = filterType
            default:
                break
            }
        }
    }
}
