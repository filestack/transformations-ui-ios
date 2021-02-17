//
//  OverlaysController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 14/12/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import AVFoundation.AVAssetExportSession
import Filestack
import FilestackSDK

class OverlaysController: EditorModuleController {
    typealias Module = Modules.Overlays

    // MARK: - Internal Properties

    let module: Module
    let viewSource: ModuleViewSource
    var renderNode: OverlaysRenderNode?
    var renderGroupNode: RenderGroupNode?

    var fsClient: Filestack.Client?

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

        let renderNode = OverlaysRenderNode()

        renderNode.center = CGPoint(x: bounds.midX, y: bounds.midY)
        renderNode.bounds = CGRect(origin: .zero, size: rect.size)

        group.add(node: renderNode)

        return renderNode
    }

    // MARK: - Lifecycle

    required init(renderNode: RenderNode?, module: EditorModule, viewSource: ModuleViewSource) {
        self.module = module as! Module
        self.viewSource = viewSource
        self.renderNode = renderNode as? OverlaysRenderNode
        self.renderGroupNode = self.renderNode?.group

        setupFilestackClient()
        showPicker()
    }

    deinit {
        cleanup()
    }
}

// MARK: - Private Functions

private extension OverlaysController {
    func setupFilestackClient() {
        let policy = Policy(expiry: .distantFuture,
                            call: [.pick, .read, .stat, .write, .writeURL, .store, .convert, .remove, .exif])

        guard let security = try? Security(policy: policy, appSecret: module.filestackAppSecret) else {
            fatalError("Unable to instantiate Security object.")
        }

        // Create `Config` object.
        let config = Filestack.Config.builder
            .with(callbackURLScheme: module.callbackURLScheme)
            .with(imageURLExportPreset: .current)
            .with(maximumSelectionLimit: 1)
            .with(availableCloudSources: module.availableCloudSources)
            .with(availableLocalSources: module.availableLocalSources)
            .with(documentPickerAllowedUTIs: ["public.image"])
            .with(cloudSourceAllowedUTIs: ["public.image"])
            .build()

        fsClient = Filestack.Client(apiKey: module.filestackAPIKey, security: security, config: config)
    }

    func cleanup() {
        /* NO-OP */
    }
}

private extension OverlaysController {
    @objc func showPicker() {
        guard let client = fsClient else { return }

        // Store options for your uploaded files.
        // Here we are saying our storage location is S3 and access for uploaded files should be public.
        let storeOptions = StorageOptions(location: .s3, access: .public)

        // Instantiate picker by passing the `StorageOptions` object we just set up.
        let picker = client.picker(storeOptions: storeOptions)

        picker.pickerDelegate = self
        picker.behavior = .storeOnly

        // Finally, present the picker on the screen.
        (viewSource as? UIViewController)?.present(picker, animated: true)
    }

    func download(handle: String) {
        let alertController = UIAlertController(title: "Fetching content",
                                                message: "Please wait",
                                                preferredStyle: .alert)

        // Present alert.
        (viewSource as? UIViewController)?.present(alertController, animated: true)

        // Download content.
        fsClient?.sdkClient.fileLink(for: handle).getContent(downloadProgress: { progress in
            alertController.message = progress.localizedDescription
        }, completionHandler: { (response) in
            if response.error == nil, let data = response.data, let image = UIImage(data: data) {
                alertController.dismiss(animated: false)
                self.updateRenderNodeImage(using: image)
                self.viewSource.discardApplyDelegate?.applySelected(sender: nil)
            } else {
                let action = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.clearRenderNodeImage()
                    self.viewSource.discardApplyDelegate?.discardSelected(sender: nil)
                }

                alertController.title = "Error"
                alertController.message = "Unable to download overlay image."
                alertController.addAction(action)
            }
        })
    }

    func updateRenderNodeImage(using image: UIImage) {
        renderNode?.image = image
        renderNode?.bounds.size.height *= (image.size.height / image.size.width)

        if let groupView = (renderNode?.group as? ViewableNode)?.view {
            renderNode?.center = CGPoint(x: groupView.bounds.midX, y: groupView.bounds.midY)
        }
    }

    func clearRenderNodeImage() {
        if let renderNode = renderNode {
            renderGroupNode?.remove(node: renderNode)
        }

        renderNode = nil
    }
}

extension OverlaysController: PickerNavigationControllerDelegate {
    func pickerPickedFiles(picker: PickerNavigationController, fileURLs: [URL]) {
        var image: UIImage? = nil

        if let fileURL = fileURLs.first, let data = try? Data(contentsOf: fileURL) {
            image = UIImage(data: data)
        }

        picker.dismiss(animated: true) {
            if let image = image {
                self.updateRenderNodeImage(using: image)
            } else {
                self.clearRenderNodeImage()
            }

            self.viewSource.discardApplyDelegate?.applySelected(sender: nil)
        }
    }

    func pickerStoredFile(picker: PickerNavigationController, response: StoreResponse) {
        picker.dismiss(animated: true) {
            if let handle = response.contents?["handle"] as? String {
                self.download(handle: handle)
            }
        }
    }

    func pickerUploadedFiles(picker: PickerNavigationController, responses: [JSONResponse]) {
        // NO-OP
    }

    func pickerReportedUploadProgress(picker: PickerNavigationController, progress: Float) {
        // NO-OP
    }
}
