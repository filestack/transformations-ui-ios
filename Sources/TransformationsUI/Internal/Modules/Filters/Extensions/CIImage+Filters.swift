//
//  CIImage+Filters.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 20/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

typealias FilterType = Modules.Filters.Commands.Filter.FilterType

private extension FilterType {
    var ciFilterName: String? {
        switch self {
        case .none: return nil
        case .chrome: return "CIPhotoEffectChrome"
        case .fade: return "CIPhotoEffectFade"
        case .instant: return "CIPhotoEffectInstant"
        case .mono: return "CIPhotoEffectMono"
        case .noir: return "CIPhotoEffectNoir"
        case .process: return "CIPhotoEffectProcess"
        case .tonal: return "CIPhotoEffectTonal"
        case .transfer: return "CIPhotoEffectTransfer"
        }
    }
}

extension CIImage {
    func applying(filterType: FilterType) -> CIImage {
        guard let ciFilterName = filterType.ciFilterName else { return self }

        return applyingFilter(ciFilterName)
    }
}
