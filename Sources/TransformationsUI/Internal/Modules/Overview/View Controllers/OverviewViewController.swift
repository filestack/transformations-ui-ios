//
//  OverviewViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

protocol OverviewViewControllerDelegate: class {
    func moduleSelected(module: EditorModule)
}

class OverviewViewController: ModuleViewController {
    // MARK: - Internal Properties

    weak var delegate: OverviewViewControllerDelegate?

    // MARK: - Private Properties

    private let modules: [EditorModule]
    private lazy var renderNode = OverviewRenderNode()

    private lazy var toolbar: StandardToolbar = {
        let toolbar = StandardToolbar(items: modules, style: .modules)

        toolbar.delegate = self

        return toolbar
    }()

    private lazy var nodesAndModules: [(EditorModule, ContainsCanvasItems)] = modules.compactMap {
        if let node = $0.viewController.getRenderNode() as? ContainsCanvasItems {
            return ($0, node)
        } else {
            return nil
        }
    }

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()

        recognizer.numberOfTapsRequired = 1
        recognizer.addTarget(self, action: #selector(handleTapGesture(recognizer:)))

        return recognizer
    }()

    // MARK: - Lifecycle

    required init(modules: [EditorModule], delegate: OverviewViewControllerDelegate? = nil) {
        self.modules = modules
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View overrides

extension OverviewViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addGestureRecognizers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeGestureRecognizers()
    }
}

// MARK: - EditorModuleVC Conformance

extension OverviewViewController {
    func getRenderNode() -> RenderNode { renderNode }
}

// MARK: - Gesture Handling

extension OverviewViewController {
    @objc func handleTapGesture(recognizer: UITapGestureRecognizer) {
        for (module, node) in nodesAndModules {
            if let canvasItem = node.canvasItem(at: recognizer.location(in: imageView)) {
                node.selectedCanvasItem = canvasItem
                delegate?.moduleSelected(module: module)
                break
            }
        }
    }
}

// MARK: - Private Functions

private extension OverviewViewController {
    func setupView() {
        stackView.addArrangedSubview(toolbar)
    }

    func addGestureRecognizers() {
        scrollView.addGestureRecognizer(tapGestureRecognizer)
    }

    func removeGestureRecognizers() {
        scrollView.removeGestureRecognizer(tapGestureRecognizer)
    }
}

// MARK: - EditorModuleVC Protocol

extension OverviewViewController: EditorModuleVC {}

// MARK: - ModulesToolbar Delegate

extension OverviewViewController: StandardToolbarDelegate {
    func toolbarItemSelected(toolbar: StandardToolbar, item: DescriptibleEditorItem, control: UIControl) {
        delegate?.moduleSelected(module: modules[control.tag])
    }
}
