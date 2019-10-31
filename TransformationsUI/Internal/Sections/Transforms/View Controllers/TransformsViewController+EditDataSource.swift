//
//  TransformsViewController+EditDataSource.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import AVFoundation
import Foundation

extension TransformsViewController: EditDataSource {
    var imageFrame: CGRect {
        let frame = AVMakeRect(aspectRatio: imageActualSize, insideRect: imageView.bounds)

        return CGRect(x: frame.origin.x.rounded(.down),
                      y: frame.origin.y.rounded(.down),
                      width: frame.width.rounded(.up),
                      height: frame.height.rounded(.up))
    }

    var imageSize: CGSize {
        return imageFrame.size
    }

    var imageOrigin: CGPoint {
        return imageFrame.origin
    }

    var imageActualSize: CGSize {
        return renderNode.outputImage.extent.size
    }
}
