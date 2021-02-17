//
//  ModuleViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 17/12/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

open class ModuleViewController: UIViewController, ModuleViewSource {
    // MARK: - Private Properties

    private var observers: [NSKeyValueObservation] = []

    // MARK: - Open Properties

    open var canvasView: UIView? {
        didSet {
            for subview in scrollView.subviews {
                subview.removeFromSuperview()
            }

            if let canvasView = canvasView {
                scrollView.addSubview(canvasView)
            }
        }
    }

    open var zoomEnabled: Bool = true {
        didSet {
            if zoomEnabled {
                recalculateMinAndMaxZoomScale()
                addObservers()
            } else {
                removeObservers()
                scrollView.minimumZoomScale = 1
                scrollView.maximumZoomScale = 1
            }
        }
    }

    open var canScrollAndZoom: Bool = true {
        didSet {
            DispatchQueue.main.async {
                self.scrollView.panGestureRecognizer.isEnabled = self.canScrollAndZoom
                self.scrollView.pinchGestureRecognizer?.isEnabled = self.canScrollAndZoom
            }
        }
    }

    open private(set) lazy var scrollView: CenteredScrollView = {
        let scrollView = CenteredScrollView()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false

        return scrollView
    }()

    // MARK: - Public Properties

    public var activeModuleController: EditorModuleController?

    public weak var discardApplyDelegate: DiscardApplyToolbarDelegate?

    public let contentView: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false

        return view
    }()

    public let stackView: UIStackView = {
        let stackView = UIStackView()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill

        return stackView
    }()
}

// MARK: - View Overrides

extension ModuleViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addObservers()
        recalculateMinAndMaxZoomScale()
        scrollView.zoomScale = scrollView.minimumZoomScale
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeObservers()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activeModuleController?.viewSourceDidLayoutSubviews()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        activeModuleController?.viewSourceTraitCollectionDidChange(previousTraitCollection)
    }
}

// MARK: - UIScrollView Delegate

extension ModuleViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasView
    }
}

// MARK: - UIPopoverPresentationController Delegate

extension ModuleViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - Private Functions

private extension ModuleViewController {
    func addObservers() {
        removeObservers()

        // Typically happens when the device orientation changes.
        observers.append(view.observe(\.bounds, options: [.new, .old]) { (view, change) in
            guard change.newValue?.size != change.oldValue?.size else { return }

            DispatchQueue.main.async {
                self.recalculateMinAndMaxZoomScale()
                self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            }
        })

        // Typically happens when an arranged view from the `stackView` is added, removed, or `isHidden` changes.
        observers.append(contentView.observe(\.bounds, options: [.new, .old]) { (view, change) in
            guard change.newValue?.size != change.oldValue?.size else { return }

            DispatchQueue.main.async { self.recalculateMinAndMaxZoomScale() }
        })

        // Start observing bounds changes in render pipeline view.
        if let canvasView = canvasView {
            observers.append(canvasView.observe(\.frame, options: [.new, .old]) { _, change in
                // Recalculate scroll view's zoom scale if dimensions changed.
                if change.oldValue?.size != change.newValue?.size {
                    DispatchQueue.main.async {
                        self.recalculateMinAndMaxZoomScale()
                        self.scrollView.zoomScale = self.scrollView.minimumZoomScale
                    }
                }
            })
        }
    }

    func removeObservers() {
        observers.removeAll()
    }

    func recalculateMinAndMaxZoomScale() {
        guard zoomEnabled else { return }
        guard let zoomedView = scrollView.delegate?.viewForZooming?(in: scrollView) else { return }
        guard scrollView.bounds.size != .zero && zoomedView.bounds.size != .zero else { return }

        let scaleX = scrollView.bounds.width / zoomedView.bounds.width
        let scaleY = scrollView.bounds.height / zoomedView.bounds.height
        let scale = min(scaleX, scaleY)

        scrollView.minimumZoomScale = scale
        scrollView.maximumZoomScale = .infinity
    }
}
