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
    weak var delegate: OverviewViewControllerDelegate?

    let modules: [EditorModule]

    lazy var renderNode = OverviewRenderNode()
    lazy var modulesToolbar = StandardToolbar(items: modules, style: .modules)

    // MARK: - Internal Functions

    func getRenderNode() -> RenderNode {
        return renderNode
    }

    // MARK: - View overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

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

// MARK: - EditorModuleVC Protocol

extension OverviewViewController: EditorModuleVC {}

// MARK: - ModulesToolbar Delegate

extension OverviewViewController: StandardToolbarDelegate {
    func toolbarItemSelected(toolbar: StandardToolbar, item: DescriptibleEditorItem, control: UIControl) {
        delegate?.moduleSelected(module: modules[control.tag])
    }
}
