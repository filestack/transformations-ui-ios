//
//  EditDataSource.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol EditDataSource: AnyObject {
    var imageFrame: CGRect { get }
    var imageSize: CGSize { get }
    var zoomScale: CGFloat { get }
    var virtualFrame: CGRect { get }

    func convertPointFromVirtualFrameToImageFrame(_ point: CGPoint) -> CGPoint
    func convertRectFromVirtualFrameToImageFrame(_ rect: CGRect) -> CGRect
}
