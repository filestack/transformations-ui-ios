//
//  EditorToolbar.swift
//  TransformationsUI
//
//  Created by Mihály Papp on 03/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

class EditorToolbar: UIToolbar {
    weak var editorDelegate: EditorToolbarDelegate?

    var space: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }

    var cancel: UIBarButtonItem {
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelected))
        cancel.tintColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
        return cancel
    }

    var done: UIBarButtonItem {
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneSelected))
        done.tintColor = editColor
        return done
    }

    var undo: UIBarButtonItem {
        let undo = imageBarButton("icon-undo", action: #selector(undoSelected))
        undo.tintColor = editColor
        return undo
    }

    var redo: UIBarButtonItem {
        let redo = imageBarButton("icon-redo", action: #selector(redoSelected))
        redo.tintColor = editColor
        return redo
    }
}

private extension EditorToolbar {
    func imageBarButton(_ imageName: String, action: Selector) -> UIBarButtonItem {
        let image = UIImage.fromFilestackBundle(imageName)
        return UIBarButtonItem(image: image, style: .plain, target: self, action: action)
    }

    var editColor: UIColor {
        return UIColor(red: 240 / 255, green: 180 / 255, blue: 0, alpha: 1)
    }
}

extension EditorToolbar {
    @objc func cancelSelected() {
        editorDelegate?.cancelSelected()
    }

    @objc func doneSelected() {
        editorDelegate?.doneSelected()
    }

    @objc func undoSelected() {
        editorDelegate?.undoSelected()
    }

    @objc func redoSelected() {
        editorDelegate?.redoSelected()
    }
}
