//
//  EditorViewController+ToolbarDelegate.swift
//  TransformationsUI
//
//  Created by Mihály Papp on 23/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

extension EditorViewController: EditorToolbarDelegate {
    func cancelSelected() {
        dismiss(animated: true) {
            self.completion?(nil)
        }
    }

    func doneSelected() {
        dismiss(animated: true) {
            let editedImage = UIImage(ciImage: self.renderPipeline.outputImage).cgImageBackedCopy()
            self.completion?(editedImage)
        }
    }

    func undoSelected() {
        editorUndoManager?.undo()

        if let state = editorUndoManager?.current {
            renderPipeline.restore(from: state)
        }
    }

    func redoSelected() {
        editorUndoManager?.redo()

        if let state = editorUndoManager?.current {
            renderPipeline.restore(from: state)
        }
    }
}
