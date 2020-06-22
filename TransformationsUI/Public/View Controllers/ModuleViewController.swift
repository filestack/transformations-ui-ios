//
//  ModuleViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 17/12/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

open class ModuleViewController: ArrangeableViewController {
    // MARK: - Private Properties

    private var imageViewImageObserver: NSKeyValueObservation?
    private var lastViewFrame: CGRect? = nil

    // MARK: - Internal Properties

    let scrollWrapperView: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true

        return view
    }()

    // MARK: - Open Properties

    open weak var delegate: EditorModuleVCDelegate?

    open var zoomEnabled: Bool = false {
        didSet { scrollView.bouncesZoom = zoomEnabled }
    }

    open var contentLayoutMargins: UIEdgeInsets {
        get { scrollWrapperView.layoutMargins }
        set { scrollWrapperView.layoutMargins = newValue }
    }

    open private(set) lazy var scrollView: CenteredScrollView = {
        let scrollView = CenteredScrollView()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        scrollView.bouncesZoom = zoomEnabled

        return scrollView
    }()

    open private(set) lazy var imageView: CIImageView = {
        let imageView = MetalImageView()

        // Start observing changes in `image` property from `imageView`.
        let observer = imageView.observe(\.image, options: [.new, .prior]) { imageView, change in
            if change.isPrior {
                // Notify that imageView's image is about to be updated.
                self.willUpdateImageView(imageView: imageView)
            } else {
                // Notify that imageView's image was just updated.
                self.didUpdateImageView(imageView: imageView)

                // Recalculate scroll view's zoom scale if dimensions changed.
                if change.oldValue??.extent != change.newValue??.extent {
                    self.recalculateZoomScale()
                }
            }
        }

        // Keep a strong reference to observer
        imageViewImageObserver = observer

        return imageView
    }()

    open private(set) lazy var discardApplyToolbar: DiscardApplyToolbar? = {
        self is Editable ? DiscardApplyToolbar(delegate: self) : nil
    }()

    // MARK: - Public Properties

    public let stackView: UIStackView = {
        let stackView = UIStackView()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.backgroundColor = .blue

        return stackView
    }()

    // MARK: - Open Overridable Functions

    /// Called right before the `imageView` is updated.
    ///
    /// - Parameter imageView: The `imageView` that is about to be updated.
    ///
    /// Should be implemented by subclasses interested in receiving this notification.
    open func willUpdateImageView(imageView: CIImageView) { }

    /// Called right after the `imageView` is updated.
    ///
    /// - Parameter imageView: The `imageView` that was just updated.
    ///
    /// Should be implemented by subclasses interested in receiving this notification.
    open func didUpdateImageView(imageView: CIImageView)  { }

    /// Returns the module represented by this class.
    ///
    /// Should be implemented by subclasses that contain an `EditorModule`.
    open func getModule() -> EditorModule? { return nil }
}

// MARK: - View Overrides

extension ModuleViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        stackView.layoutIfNeeded()

        if lastViewFrame != view.frame {
            lastViewFrame = view.frame
            recalculateZoomScale()
        }
    }
}

// MARK: - UIScrollView Delegate

extension ModuleViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

// MARK: - DiscardApplyToolbar Delegate

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

// MARK: - Private Functions

private extension ModuleViewController {
    func recalculateZoomScale() {
        guard let zoomedView = scrollView.delegate?.viewForZooming?(in: scrollView) else { return }
        guard scrollView.bounds.size != .zero && zoomedView.bounds.size != .zero else { return }

        let scaleX = scrollView.bounds.width / zoomedView.bounds.width
        let scaleY = scrollView.bounds.height / zoomedView.bounds.height
        let scale = min(scaleX, scaleY)

        scrollView.minimumZoomScale = scale
        scrollView.maximumZoomScale = zoomEnabled ? .infinity : scale
        scrollView.zoomScale = scale

        scrollView.setNeedsLayout()
    }
}
