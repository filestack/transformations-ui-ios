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

    // MARK: - Private Properties

    private let fsClient: Filestack.Client
    private var selectedImage: UIImage?

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
        self.fsClient = (module as! RequiresFSClient).fsClient!

        showPicker()
    }

    deinit {
        cleanup()
    }
}

// MARK: - Private Functions

private extension OverlaysController {
    func cleanup() {
        /* NO-OP */
    }
}

private extension OverlaysController {
    @objc func showPicker() {
        // Store options for your uploaded files.
        // Here we are saying our storage location is S3 and access for uploaded files should be public.
        let storeOptions = StorageOptions(location: .s3, access: .public)

        // Instantiate picker by passing the `StorageOptions` object we just set up.
        let picker = fsClient.picker(storeOptions: storeOptions)

        picker.pickerDelegate = self
        picker.behavior = .storeOnly

        // Finally, present the picker on the screen.
        (viewSource as? UIViewController)?.present(picker, animated: true)
    }

    func download(picker: PickerNavigationController, handle: String, completion: @escaping ((UIImage?) -> Void)) {
        let alertController = UIAlertController(title: "Fetching content",
                                                message: "Please wait",
                                                preferredStyle: .alert)

        // Present alert.
        picker.present(alertController, animated: true)

        // Download content.
        fsClient.sdkClient.fileLink(for: handle).getContent(downloadProgress: { progress in
            alertController.message = progress.localizedDescription
        }, completionHandler: { (response) in
            if response.error == nil, let data = response.data, let image = UIImage(data: data) {
                alertController.dismiss(animated: false)
                completion(image)
            } else {
                let action = UIAlertAction(title: "OK", style: .default) { (action) in
                    completion(nil)
                }

                alertController.title = "Error"
                alertController.message = "Unable to download overlay image."
                alertController.addAction(action)
            }
        })
    }
}

extension OverlaysController: PickerNavigationControllerDelegate {
    func pickerPickedFiles(picker: PickerNavigationController, fileURLs: [URL]) {
        if let fileURL = fileURLs.first, let data = try? Data(contentsOf: fileURL) {
            selectedImage = UIImage(data: data)
        }

        picker.dismiss(animated: true)
    }

    func pickerStoredFile(picker: PickerNavigationController, response: StoreResponse) {
        if let handle = response.contents?["handle"] as? String {
            download(picker: picker, handle: handle) { image in
                self.selectedImage = image
                picker.dismiss(animated: true)
            }
        }
    }

    func pickerUploadedFiles(picker: PickerNavigationController, responses: [JSONResponse]) {
        // NO-OP
    }

    func pickerWasDismissed(picker: PickerNavigationController) {
        if let selectedImage = selectedImage {
            renderNode?.image = selectedImage
            renderNode?.center(for: selectedImage.size)
            viewSource.discardApplyDelegate?.applySelected(sender: nil)
        } else {
            viewSource.discardApplyDelegate?.discardSelected(sender: nil)
        }
    }
}
