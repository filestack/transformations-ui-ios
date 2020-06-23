//
//  EditorModule.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public protocol EditorModuleVC: UIViewController {
    /// Returns the `CIImageView` that is used to render images on this view controller.
    var imageView: CIImageView { get }

    /// Returns the delegate for this view controller.
    var delegate: EditorModuleVCDelegate? { get set }

    /// Returns an `UIView` associated to this view controller, may be `nil` if no title is required.
    func getTitleView() -> UIView?

    /// Returns the `RenderNode` associated to this view controller.
    func getRenderNode() -> RenderNode

    /// Returns the `EditorModule` associated to this view controller, or `nil` if none.
    func getModule() -> EditorModule?

    /// Called right after the editor restored a snapshot.
    ///
    /// Should be implemented by subclasses interested in receiving this notification.
    func editorDidRestoreSnapshot()

    /// Called right before the `imageView` is updated.
    ///
    /// - Parameter imageView: The `imageView` that is about to be updated.
    ///
    /// Should be implemented by subclasses interested in receiving this notification.
    func willUpdateImageView(imageView: CIImageView)

    /// Called right after the `imageView` is updated.
    ///
    /// - Parameter imageView: The `imageView` that was just updated.
    ///
    /// Should be implemented by subclasses interested in receiving this notification.
    func didUpdateImageView(imageView: CIImageView)
}

// MARK: - Default Implementations

extension EditorModuleVC {
    public func getTitleView() -> UIView? {
        return nil
    }

    public func getModule() -> EditorModule? {
        return nil
    }

    public func editorDidRestoreSnapshot() {
        // NO-OP
    }

    public func willUpdateImageView(imageView: CIImageView) {
        // NO-OP
    }

    public func didUpdateImageView(imageView: CIImageView) {
        // NO-OP
    }
}
