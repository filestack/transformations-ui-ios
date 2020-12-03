//
//  ImageHandleView.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 27/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

private extension UIImage {
    func tinted(with color: UIColor, scale: CGFloat) -> UIImage? {
        defer { UIGraphicsEndImageContext() }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()

        withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

class ImageHandleView: UIView, Draggable {
    let image: UIImage
    let tolerance: CGFloat
    let handleType: HandleType

    lazy var tintedImage: UIImage? = image.tinted(with: .black, scale: contentScaleFactor)

    // MARK: - Lifecycle

    init(center: CGPoint, image: UIImage, tolerance: CGFloat = 0, type handleType: HandleType) {
        self.image = image
        self.tolerance = tolerance
        self.handleType = handleType

        let sizeWithTolerance = image.size.adding(width: tolerance * 2, height: tolerance * 2)

        let frame = CGRect(origin: center, size: sizeWithTolerance)
            .offsetBy(dx: -sizeWithTolerance.width / 2, dy: -sizeWithTolerance.height / 2)

        super.init(frame: frame)

        self.isOpaque = false
        self.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Overrides

extension ImageHandleView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {return}
        let imageRect = bounds.insetBy(dx: tolerance, dy: tolerance)

        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: imageRect.insetBy(dx: 4, dy: 4))

        context.setLineWidth(2)
        context.setStrokeColor(UIColor.black.cgColor)
        context.strokeEllipse(in: imageRect.insetBy(dx: 4, dy: 4))

        tintedImage?.draw(in: imageRect)
    }
}
