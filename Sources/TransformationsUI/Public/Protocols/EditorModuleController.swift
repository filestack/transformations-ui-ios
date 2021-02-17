//
//  EditorModuleController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol ModuleViewSource: class {
    var canvasView: UIView? { get }
    var scrollView: CenteredScrollView { get }
    var stackView: UIStackView { get }
    var contentView: UIView { get }
    var canScrollAndZoom: Bool { set get }
    var zoomEnabled: Bool { set get }
    var traitCollection: UITraitCollection { get }
    var discardApplyDelegate: DiscardApplyToolbarDelegate? { get }
}

public protocol EditorModuleController: class {
    /// Returns a newly instantiated `RenderNode` given an `EditorModule` and `RenderGroupNode`.
    static func renderNode(for module: EditorModule, in group: RenderGroupNode) -> RenderNode?

    /// :nodoc:
    var viewSource: ModuleViewSource { get }

    /// Returns the `EditorModule` associated to this view controller, or `nil` if none.
    func getModule() -> EditorModule?

    /// Returns the `RenderNode` associated to this view controller.
    func getRenderNode() -> RenderNode?

    /// Returns an `UIView` associated to this view controller, may be `nil` if no title is required.
    func getTitleView() -> UIView?

    /// Called right after the editor restored a snapshot.
    ///
    /// Should be implemented by subclasses interested in receiving this notification.
    func editorDidRestoreSnapshot()

    /// Called to notify the module controller that the view managed by the `viewSource` has just laid out its subviews.
    func viewSourceDidLayoutSubviews()

    /// Called to notify the module controller that the trait collection managed by the `viewSource` did change.
    func viewSourceTraitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)

    /// Instantiates a new module controller with a given `RenderNode`, `EditorModule` and `ModuleViewSource`.
    init(renderNode: RenderNode?, module: EditorModule, viewSource: ModuleViewSource)
}

// MARK: - Default Implementations

extension EditorModuleController {
    public static func renderNode(for module: EditorModule, in group: RenderGroupNode) -> RenderNode? { return nil }
    public func getTitleView() -> UIView? { return nil }
    public func getModule() -> EditorModule? { return nil }
    public func getRenderNode() -> RenderNode? { nil }
    public func editorDidRestoreSnapshot() { /* NO-OP */ }
    public func viewSourceDidLayoutSubviews() { /* NO-OP */ }
    public func viewSourceTraitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) { /* NO-OP */ }
}
