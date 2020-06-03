//
//  ModuleViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 17/12/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

open class ModuleViewController: ArrangeableViewController {
    private var lastImage: CIImage? = nil
    private var lastViewFrame: CGRect? = nil

    open weak var delegate: EditorModuleVCDelegate?

    open var maximumZoomScale: CGFloat = .infinity {
        didSet { scrollView.maximumZoomScale = maximumZoomScale }
    }

    open lazy var scrollView: CenteredScrollView = {
        let scrollView = CenteredScrollView()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.delegate = self
        scrollView.clipsToBounds = true

        return scrollView
    }()

    open lazy var imageView: CIImageView = {
        let imageView = MetalImageView()

        imageView.imageViewDelegate = self

        return imageView
    }()

    public let stackView: UIStackView = {
        let stackView = UIStackView()

        stackView.axis = .vertical
        stackView.distribution = .fill

        return stackView
    }()

    public lazy var discardApplyToolbar: DiscardApplyToolbar? = {
        if self is Editable {
            let toolbar = DiscardApplyToolbar()

            toolbar.delegate = self

            return toolbar
        } else {
            return nil
        }
    }()

    open func getModule() -> EditorModule? {
        return nil
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        recalculateZoomScale()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if lastViewFrame != view.frame {
            lastViewFrame = view.frame
            recalculateZoomScale()
        }
    }
}

extension ModuleViewController: UIScrollViewDelegate {
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension ModuleViewController: CIImageViewDelegate {
    open func imageChanged(image: CIImage?) {
        if lastImage?.extent != image?.extent {
            recalculateZoomScale()
        }

        lastImage = image
    }
}

private extension ModuleViewController {
    func recalculateZoomScale() {
        guard let zoomedView = scrollView.delegate?.viewForZooming?(in: scrollView) else { return }
        guard scrollView.bounds.size != .zero && zoomedView.bounds.size != .zero else { return }

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

extension ModuleViewController: DiscardApplyToolbarDelegate {
    public func discardSelected(sender: UIButton) {
        if let module = getModule() {
            delegate?.moduleWantsToDiscardChanges(module: module)
        }
    }

    public func applySelected(sender: UIButton) {
        if let module = getModule() {
            delegate?.moduleWantsToApplyChanges(module: module)
        }
    }
}
