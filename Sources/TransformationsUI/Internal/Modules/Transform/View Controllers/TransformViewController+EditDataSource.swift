//
//  TransformViewController+EditDataSource.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import AVFoundation
import Foundation

extension TransformViewController: EditDataSource {
    var imageFrame: CGRect { imageView.bounds }
    var imageSize: CGSize { renderNode.outputImage.extent.size }
    var zoomScale: CGFloat { scrollView.zoomScale }
    var virtualFrame: CGRect { AVMakeRect(aspectRatio: imageSize, insideRect: scrollView.bounds) }

    func convertPointFromVirtualFrameToImageFrame(_ point: CGPoint) -> CGPoint {
        return scrollView.convert(point, to: imageView)
    }

    func convertRectFromVirtualFrameToImageFrame(_ rect: CGRect) -> CGRect {
        return scrollView.convert(rect, to: imageView)
    }
}
