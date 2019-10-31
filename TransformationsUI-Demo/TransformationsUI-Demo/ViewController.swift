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

        imageView.image = UIImage(named: "picture")
    }

    // MARK: - Actions

    @IBAction func presentTransformationsUI(_ sender: AnyObject) {
        guard let image = imageView.image else { return }

        let config = Config()
        let transformationsUI = TransformationsUI(with: config)

        transformationsUI.delegate = self

        if let editorVC = transformationsUI.editor(with: image) {
            present(editorVC, animated: true)
        }
    }
}

extension ViewController: TransformationsUIDelegate {
    func editorDismissed(with image: UIImage?) {
        editedImageView.image = image ?? UIImage(named: "placeholder")
    }
}
