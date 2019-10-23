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

        let transformationsUI = TransformationsUI()

        let editorVC = transformationsUI.editor(with: image) { outImage in
            self.editedImageView.image = outImage ?? UIImage(named: "placeholder")
        }

        present(editorVC, animated: true)
    }
}
