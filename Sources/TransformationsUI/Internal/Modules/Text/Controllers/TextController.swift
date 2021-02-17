//
//  TextViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 07/01/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import AVFoundation.AVUtilities
import UIKit

class TextController: EditorModuleController {
    typealias Module = Modules.Text

    // MARK: - Internal Properties

    let module: Module
    let viewSource: ModuleViewSource
    var renderNode: TextRenderNode
    var renderGroupNode: RenderGroupNode?

    // MARK: - Private Properties

    private lazy var toolbar: TextToolbar = {
        let toolbar: TextToolbar

        if viewSource.traitCollection.horizontalSizeClass == .regular {
            toolbar = TextToolbar(commandsInGroups: [Array(module.commandsInGroups.joined())], style: .segments)
        } else {
            toolbar = TextToolbar(commandsInGroups: module.commandsInGroups, style: .twoRowSegments)
        }

        toolbar.delegate = self

        return toolbar
    }()

    private lazy var inputAccessoryView: UIView = {
        let discardApplyToolbar = DiscardApplyToolbar()

        discardApplyToolbar.delegate = viewSource.discardApplyDelegate
        discardApplyToolbar.translatesAutoresizingMaskIntoConstraints = false

        let stackView = StackViewWithIntrinsicHeight(arrangedSubviews: [toolbar, discardApplyToolbar])

        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return VisualFXWrapperView(wrapping: stackView, usingBlurEffect: Constants.ViewEffects.blur)
    }()

    // MARK: - View Overrides

    func getModule() -> EditorModule? { module }
    func getRenderNode() -> RenderNode? { renderNode }

    func editorDidRestoreSnapshot() {
        updateToolbar()

        renderNode.resignFirstResponder()

        if let updatedRenderNode = renderGroupNode?.node(with: renderNode.uuid) as? TextRenderNode, updatedRenderNode != renderNode {
            // Re-associate render node by existing UUID and render group node in case a snapshot restoration
            // recreated it while this module controller was active.
            cleanup()
            renderNode = updatedRenderNode
            renderGroupNode = renderNode.group
            setup()
        }

        renderNode.becomeFirstResponder()
    }

    // MARK: - Static Overrides

    static func renderNode(for module: EditorModule, in group: RenderGroupNode) -> RenderNode? {
        guard let module = module as? Module else { return nil }
        guard let groupView = (group as? ViewableNode)?.view else { return nil }

        let bounds = groupView.bounds
        let inset: CGFloat = bounds.width * 0.10

        let rect = bounds.insetBy(dx: bounds.size.width > inset ? inset : 0,
                                  dy: bounds.size.height > inset ? inset : 0)

        let renderNode = TextRenderNode()

        renderNode.center = CGPoint(x: rect.midX, y: rect.midY)
        renderNode.bounds = CGRect(origin: .zero, size: rect.size)
        renderNode.placeholder = "Type here"
        renderNode.fontFamily = module.defaultFontFamily
        renderNode.fontSize = module.defaultFontSize
        renderNode.fontStyle = module.defaultFontStyle
        renderNode.textColor = module.defaultFontColor
        renderNode.textAlignment = module.defaultTextAlignment

        group.add(node: renderNode)

        return renderNode
    }

    // MARK: - Lifecycle

    required init(renderNode: RenderNode?, module: EditorModule, viewSource: ModuleViewSource) {
        self.module = module as! Module
        self.viewSource = viewSource
        self.renderNode = renderNode as! TextRenderNode
        self.renderGroupNode = self.renderNode.group

        setup()
    }

    deinit {
        cleanup()
    }
}

// MARK: - Private Functions

private extension TextController {
    func setup() {
        addKeyboardObservers()

        updateToolbar()

        guard let groupView = (renderNode.group as? ViewableNode)?.view else { return }

        let hInset: CGFloat = groupView.bounds.width * 2
        let vInset: CGFloat = groupView.bounds.height * 2

        viewSource.canScrollAndZoom = false
        viewSource.zoomEnabled = false
        viewSource.scrollView.minimumZoomScale = 0.01
        viewSource.scrollView.maximumZoomScale = .infinity
        viewSource.scrollView.extraContentInset = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset)

        renderNode.isEditable = true
        renderNode.inputAccessoryView = inputAccessoryView
        renderNode.inputAccessoryView?.isHidden = false

        renderNode.becomeFirstResponder()
        renderNode.reloadInputViews()
    }

    func cleanup() {
        removeKeyboardObservers()

        viewSource.canScrollAndZoom = true
        viewSource.zoomEnabled = true
        viewSource.scrollView.zoomScale = viewSource.scrollView.minimumZoomScale
        viewSource.scrollView.extraContentInset = .zero

        renderNode.isEditable = false
        renderNode.inputAccessoryView = nil
    }

    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
    }

    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardDidShowNotification,
                                                  object: nil)
    }

    func updateToolbar() {
        toolbar.fontFamily = renderNode.fontFamily
        toolbar.fontColor = renderNode.textColor
        toolbar.fontStyle = renderNode.fontStyle
        toolbar.textAlignment = renderNode.textAlignment
    }

    @objc func keyboardDidShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        // Convert endFrame to `contentView` coordinates
        let kbRect = viewSource.contentView.convert(endFrame, from: nil)
        let intersectRect = viewSource.contentView.bounds.intersection(kbRect)

        let visibleRectSize = viewSource.scrollView.bounds.size.adding(width: 0,
                                                                            height: -intersectRect.height)

        let viewFrame = renderNode.view.frame

        var zoomRect = AVMakeRect(aspectRatio: visibleRectSize, insideRect: viewFrame)

        var ratio = viewFrame.height / zoomRect.height

        if abs(ratio.distance(to: 1.0)) < 0.0001 {
            ratio = viewFrame.width / zoomRect.width
        }

        zoomRect = zoomRect.insetBy(dx: -((zoomRect.width * ratio) - zoomRect.width) / 2,
                                        dy: -((zoomRect.height * ratio) - zoomRect.height) / 2)

        // Add 10% padding
        zoomRect = zoomRect
            .insetBy(dx: -zoomRect.width * 0.10,
                     dy: -zoomRect.height * 0.10)

        // Add the hidden area covered by the keyboard.
        zoomRect.size.height = (viewSource.scrollView.bounds.height / viewSource.scrollView.bounds.width) *
            zoomRect.size.width

        viewSource.scrollView.zoom(to: zoomRect, animated: true)
    }
}

// MARK: - Editable Conformance

extension TextController: Editable {
    func applyEditing() {
        renderNode.sizeToFit()
        removeKeyboardObservers()
    }

    func cancelEditing() {
        removeKeyboardObservers()
    }
}

extension TextController {
    func showPopup(_ controller: UIViewController, sourceView: UIView) {
        controller.modalPresentationStyle = .popover

        guard let presentationController = controller.presentationController as? UIPopoverPresentationController else {
            return
        }

        presentationController.sourceView = sourceView
        presentationController.sourceRect = sourceView.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        presentationController.delegate = (viewSource as? UIPopoverPresentationControllerDelegate)

        (viewSource as? UIViewController)?.present(controller, animated: true)
    }
}
