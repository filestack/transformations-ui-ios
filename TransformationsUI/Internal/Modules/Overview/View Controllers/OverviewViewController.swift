//
//  OverviewViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

protocol OverviewViewControllerDelegate: EditorModuleVCDelegate {
    func moduleSelected(module: EditorModule)
}

class OverviewViewController: ModuleViewController, EditorModuleVC, UIGestureRecognizerDelegate {
    //weak var delegate: OverviewViewControllerDelegate?

    private weak var subDelegate: OverviewViewControllerDelegate?

    override var delegate: EditorModuleVCDelegate? {
        get { return self.subDelegate }
        set { self.subDelegate = newValue as! OverviewViewControllerDelegate? }
    }

    let modules: [EditorModule]

    lazy var renderNode = OverviewRenderNode()
    lazy var modulesToolbar = ModulesToolbar()

    // MARK: - Lifecycle Functions

    required init(modules: [EditorModule]) {
        self.modules = modules

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal Functions

    func getRenderNode() -> RenderNode {
        return renderNode
    }

    // MARK: - View overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateImageView()
    }
}


extension OverviewViewController: ModulesToolbarDelegate {
    func moduleSelected(sender: UIButton) {
        subDelegate?.moduleSelected(module: modules[sender.tag])
    }
}
