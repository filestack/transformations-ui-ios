//
//  ModuleViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 17/12/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public class ModuleViewController: ArrangeableViewController {
    public var maximumZoomScale: CGFloat = 2 {
        didSet { scrollView.maximumZoomScale = maximumZoomScale }
    }

    public lazy var scrollView: CenteredScrollView = {
        let scrollView = CenteredScrollView()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.maximumZoomScale = self.maximumZoomScale
        scrollView.delegate = self
        scrollView.clipsToBounds = false

        return scrollView
    }()

    public lazy var imageView: CIImageView = {
        let imageView = MetalImageView()

        imageView.imageViewDelegate = self

        return imageView
    }()
}

extension ModuleViewController {
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recalculateZoomScale()
    }
}

extension ModuleViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension ModuleViewController: CIImageViewDelegate {
    public func imageChanged(image: CIImage?) {
        recalculateZoomScale()
    }
}

private extension ModuleViewController {
    func recalculateZoomScale() {
        guard let zoomedView = scrollView.delegate?.viewForZooming?(in: scrollView) else { return }

        // Reset minimum zoom scale
        if scrollView.bounds.width <= scrollView.bounds.height {
            scrollView.minimumZoomScale = scrollView.bounds.width / zoomedView.bounds.width
        } else {
            scrollView.minimumZoomScale = scrollView.bounds.height / zoomedView.bounds.height
        }

        // Reset zoom scale
        scrollView.zoomScale = scrollView.minimumZoomScale
    }
}
