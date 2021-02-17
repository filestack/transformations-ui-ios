//
//  StickersController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 14/12/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

class StickersController: EditorModuleController {
    typealias Module = Modules.Stickers

    // MARK: - Internal Properties

    let module: Module
    let viewSource: ModuleViewSource
    var renderNode: StickersRenderNode
    var renderGroupNode: RenderGroupNode?

    // MARK: - View Overrides

    func getModule() -> EditorModule? { module }
    func getRenderNode() -> RenderNode? { renderNode }
    func editorDidRestoreSnapshot() { /* NO-OP */ }

    // MARK: - Static Overrides

    static func renderNode(for module: EditorModule, in group: RenderGroupNode) -> RenderNode? {
        guard let groupView = (group as? ViewableNode)?.view else { return nil }

        let bounds = groupView.bounds
        let size: CGFloat = min(bounds.width, bounds.height) * 0.90
        let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))

        let renderNode = StickersRenderNode()

        renderNode.center = CGPoint(x: bounds.midX, y: bounds.midY)
        renderNode.bounds = CGRect(origin: .zero, size: rect.size)

        group.add(node: renderNode)

        return renderNode
    }

    // MARK: - Lifecycle

    required init(renderNode: RenderNode?, module: EditorModule, viewSource: ModuleViewSource) {
        self.module = module as! Module
        self.viewSource = viewSource
        self.renderNode = renderNode as! StickersRenderNode
        self.renderGroupNode = self.renderNode.group

        setup()
        showPickSticker()
    }

    deinit {
        cleanup()
    }
}

// MARK: - Private Functions

private extension StickersController {
    func setup() { /* NO-OP */ }
    func cleanup() { /* NO-OP */ }
}

extension StickersController {
    @objc func showPickSticker() {
        let stickerPickerVC = StickersPickerViewController()

        stickerPickerVC.title = "Pick Sticker"
        stickerPickerVC.delegate = self

        if #available(iOS 13.0, *) {
            stickerPickerVC.isModalInPresentation = true
        }

        stickerPickerVC.elements = module.stickers
        stickerPickerVC.selectedElement = renderNode.image
        stickerPickerVC.selectedSection = renderNode.section

        let controller = UINavigationController(rootViewController: stickerPickerVC)

        (viewSource as? UIViewController)?.present(controller, animated: true)
    }
}

extension StickersController: StickersPickerViewControllerDelegate {
    func stickersPickerViewControllerDismissed(with image: UIImage?, in section: String?) {
        if let image = image, let section = section {
            renderNode.image = image
            renderNode.section = section
            viewSource.discardApplyDelegate?.applySelected(sender: nil)
        } else {
            if renderNode.image == nil {
                renderGroupNode?.remove(node: renderNode)
            }

            viewSource.discardApplyDelegate?.discardSelected(sender: nil)
        }
    }
}
