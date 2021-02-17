//
//  BorderController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 10/08/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import UberSegmentedControl

class BorderController: EditorModuleController {
    typealias Module = Modules.Border

    // MARK: - Internal Properties

    let module: Module
    let renderNode: BorderRenderNode
    let viewSource: ModuleViewSource

    private(set) var detailToolbar: BoundedRangeCommandToolbar?
    
    // MARK: - Private Properties
    
    private(set) lazy var toolbar: BorderToolbar = {
        let toolbar = BorderToolbar(commands: module.commands, style: .segments)

        toolbar.delegate = self

        return toolbar
    }()

    private(set) lazy var toolbarStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [toolbar])

        stackView.axis = .vertical

        return stackView
    }()

    private(set) lazy var toolbarFXWrapperView: UIView = {
        VisualFXWrapperView(wrapping: toolbarStack, usingBlurEffect: Constants.ViewEffects.blur)
    }()

    // MARK: - View Overrides

    func getModule() -> EditorModule? { module }
    func getRenderNode() -> RenderNode? { renderNode }
    func editorDidRestoreSnapshot() { resetControls() }

    // MARK: - Lifecycle

    required init(renderNode: RenderNode?, module: EditorModule, viewSource: ModuleViewSource) {
        self.module = module as! Module
        self.renderNode = renderNode as! BorderRenderNode
        self.viewSource = viewSource
        setup()
    }

    deinit {
        cleanup()
    }
}

// MARK: - Editable Conformance

extension BorderController: Editable {
    func applyEditing() { /* NO-OP */ }
    func cancelEditing() { /* NO-OP */ }
}

// MARK: - Internal Functions

extension BorderController {
    func setupDetailToolbar(for command: BoundedRangeCommand) {
        if detailToolbar == nil {
            let detailToolbar = BoundedRangeCommandToolbar(command: command, style: .boundedRangeCommand)
            detailToolbar.delegate = self
            self.detailToolbar = detailToolbar
        } else if let detailToolbar = detailToolbar, detailToolbar.command.uuid != command.uuid {
            detailToolbar.command = command
        }

        if let detailToolbar = detailToolbar, !toolbarStack.arrangedSubviews.contains(detailToolbar) {
            // Add detail toolbar before `toolbar`
            if let idx = toolbarStack.arrangedSubviews.firstIndex(of: toolbar) {
                toolbarStack.insertArrangedSubview(detailToolbar, at: idx)
            }
        }

        updateDetailToolbar()
    }

    func updateDetailToolbar() {
        guard let detailToolbar = detailToolbar else { return }

        switch detailToolbar.command {
        case is Module.Commands.Width:
            detailToolbar.updateValue(value: Double(renderNode.width))
        case is Module.Commands.Opacity:
            detailToolbar.updateValue(value: Double(renderNode.opacity))
        default:
            break
        }

        viewSource.stackView.setNeedsLayout()
    }
}

// MARK: - Private Functions

private extension BorderController {
    func setup() {
        viewSource.stackView.addArrangedSubview(toolbarFXWrapperView)
        resetControls()
    }

    func cleanup() {
        toolbarFXWrapperView.removeFromSuperview()
    }

    func resetControls() {
        toolbar.color = renderNode.color

        // Select first item in toolbar by default.
        toolbar.widthControl?.selectedSegmentIndex = .zero
        toolbar.opacityControl?.selectedSegmentIndex = UberSegmentedControl.noSegment

        
        if let command = toolbar.selectedDescriptibleItem as? BoundedRangeCommand {
            setupDetailToolbar(for: command)
        }
    }
}

extension BorderController {
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
