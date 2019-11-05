//
//  TransformsToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

protocol TransformsToolbarDelegate: class {
    func rotateSelected()
    func cropSelected()
    func circleSelected()
    func saveSelected()
}

class TransformsToolbar: UIToolbar {
    weak var editorDelegate: TransformsToolbarDelegate?

    var space: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }

    var rotate: UIBarButtonItem {
        let rotate = imageBarButton("icon-rotate", action: #selector(rotateSelected))
        rotate.tintColor = .white
        return rotate
    }

    var crop: UIBarButtonItem {
        let crop = imageBarButton("icon-crop", action: #selector(cropSelected))
        crop.tintColor = .white
        return crop
    }

    var circle: UIBarButtonItem {
        let circle = imageBarButton("icon-circle", action: #selector(circleSelected))
        circle.tintColor = .white
        return circle
    }

    var save: UIBarButtonItem {
        let save = imageBarButton("icon-tick", action: #selector(saveSelected))
        save.tintColor = editColor
        return save
    }

    var finish: UIBarButtonItem {
        return isEditing ? save : space
    }

    var isEditing: Bool = false {
        didSet {
            setupItems()
        }
    }

    // MARK: - Lifecycle Functions

    init() {
        super.init(frame: .infinite)
        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Functions

    private func setupItems() {
        setItems([space, space, rotate, crop, circle, space, finish], animated: false)
    }

    private func setupView() {
        setupItems()
        barTintColor = .black
        backgroundColor = UIColor(white: 31 / 255, alpha: 1)
    }

    private func imageBarButton(_ imageName: String, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(image: .fromFrameworkBundle(imageName), style: .plain, target: self, action: action)
    }

    private var editColor: UIColor {
        return UIColor(red: 240 / 255, green: 180 / 255, blue: 0, alpha: 1)
    }
}

extension TransformsToolbar {
    @objc func rotateSelected() {
        editorDelegate?.rotateSelected()
    }

    @objc func cropSelected() {
        editorDelegate?.cropSelected()
    }

    @objc func circleSelected() {
        editorDelegate?.circleSelected()
    }

    @objc func saveSelected() {
        editorDelegate?.saveSelected()
    }
}
