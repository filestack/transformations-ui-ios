//
//  TransformViewController+EditDataSource.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import AVFoundation.AVUtilities
import Foundation
import TransformationsUIShared

extension TransformController: EditDataSource {
    var imageView: CIImageView { (renderNode.group! as! ViewableNode).view as! CIImageView }
    var imageFrame: CGRect { imageView.bounds }
    var imageSize: CGSize { renderNode.outputImage.extent.size }
    var zoomScale: CGFloat { viewSource.scrollView.zoomScale }
    var virtualFrame: CGRect { AVMakeRect(aspectRatio: imageSize, insideRect: viewSource.scrollView.bounds) }

    func convertPointFromVirtualFrameToImageFrame(_ point: CGPoint) -> CGPoint {
        return viewSource.scrollView.convert(point, to: imageView)
    }

    func convertRectFromVirtualFrameToImageFrame(_ rect: CGRect) -> CGRect {
        return viewSource.scrollView.convert(rect, to: imageView)
    }
}
