//
//  ViewController.swift
//  TransformationsUI-Demo
//
//  Created by Ruben Nine on 22/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit
import TransformationsUI

class ViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var editedImageView: UIImageView!

    // MARK: - Lifecycle Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }

        imageView.image = UIImage(named: "picture")
    }

    // MARK: - Actions

    @IBAction func presentTransformationsUI(_ sender: AnyObject) {
        guard let image = imageView.image else { return }

        let modules = StandardModules()
        typealias TransformCommands = StandardModules.Transforms.Commands

        modules.transforms.commands = [
            TransformCommands.Rotate(),
            TransformCommands.Crop(type: .rect),
            TransformCommands.Crop(type: .circle)
        ]

        let transformationsUI = TransformationsUI(with: Config(modules: modules))

        transformationsUI.delegate = self

        if let editorVC = transformationsUI.editor(with: image) {
            editorVC.modalPresentationStyle = .fullScreen
            present(editorVC, animated: true)
        }
    }
}

extension ViewController: TransformationsUIDelegate {
    func editorDismissed(with image: UIImage?) {
        editedImageView.image = image ?? UIImage(named: "placeholder")
    }
}
