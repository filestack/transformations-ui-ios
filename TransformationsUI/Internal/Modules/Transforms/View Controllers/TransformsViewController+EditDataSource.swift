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
        return AVMakeRect(aspectRatio: imageActualSize, insideRect: imageView.bounds)
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

    var zoomScale: CGFloat {
        return scrollView.zoomScale
    }

    var virtualFrame: CGRect {
        return AVMakeRect(aspectRatio: imageActualSize, insideRect: scrollView.bounds)
    }

    func convertPointFromVirtualFrameToImageFrame(_ point: CGPoint) -> CGPoint {
        return scrollView.convert(point, to: imageView)
    }

    func convertRectFromVirtualFrameToImageFrame(_ rect: CGRect) -> CGRect {
        return scrollView.convert(rect, to: imageView)
    }
}
