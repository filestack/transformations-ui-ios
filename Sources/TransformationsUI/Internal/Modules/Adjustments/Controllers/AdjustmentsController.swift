//
//  AdjustmentsController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 21/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

class AdjustmentsController: EditorModuleController {
    typealias Module = Modules.Adjustments

    // MARK: - Internal Properties

    let renderNode: AdjustmentsRenderNode
    let viewSource: ModuleViewSource

    private(set) var detailToolbar: BoundedRangeCommandToolbar?

    private(set) lazy var toolbar: StandardToolbar = {
        let toolbar = StandardToolbar(items: module.commands, style: .commands)

        toolbar.shouldHighlightSelectedItem = true
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

    // MARK: - Private Properties

    private let module: Module

    // MARK: - Lifecycle

    required init(renderNode: RenderNode?, module: EditorModule, viewSource: ModuleViewSource) {
        self.module = module as! Module
        self.renderNode = renderNode as! AdjustmentsRenderNode
        self.viewSource = viewSource

        setup()
    }

    deinit {
        cleanup()
    }

    // MARK: - View Overrides

    func getModule() -> EditorModule? { module }
    func getRenderNode() -> RenderNode? { renderNode }
    func editorDidRestoreSnapshot() { updateDetailToolbar() }
}

// MARK: - Internal Functions

extension AdjustmentsController {
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
        case is Module.Commands.Blur:
            detailToolbar.updateValue(value: renderNode.blurAmount)
        case is Module.Commands.Brightness:
            detailToolbar.updateValue(value: renderNode.brightness)
        case is Module.Commands.Contrast:
            detailToolbar.updateValue(value: renderNode.contrast)
        case is Module.Commands.Gamma:
            detailToolbar.updateValue(value: Double(renderNode.gamma.x), at: 0)
            detailToolbar.updateValue(value: Double(renderNode.gamma.y), at: 1)
            detailToolbar.updateValue(value: Double(renderNode.gamma.z), at: 2)
        case is Module.Commands.HueRotation:
            detailToolbar.updateValue(value: renderNode.hueRotationAngle)
        default:
            break
        }

        viewSource.stackView.setNeedsLayout()
    }
}

// MARK: - Private Functions

private extension AdjustmentsController {
    func setup() {
        viewSource.stackView.addArrangedSubview(toolbarFXWrapperView)
        resetControls()
    }

    func cleanup() {
        toolbarFXWrapperView.removeFromSuperview()
    }

    func resetControls() {
        // Select first item in toolbar by default.
        toolbar.selectedItem = toolbar.items.first

        if let command = toolbar.selectedDescriptibleItem as? BoundedRangeCommand {
            setupDetailToolbar(for: command)
        }
    }
}

// MARK: - Editable Conformance

extension AdjustmentsController: Editable {
    func applyEditing() { /* NO-OP */ }
    func cancelEditing() { /* NO-OP */ }
}
