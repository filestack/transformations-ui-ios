//
//  EditorViewController+ViewSetup.swift
//  TransformationsUI
//
//  Created by Mihály Papp on 23/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

extension EditorViewController {
    func setupView() {
        view.backgroundColor = backgroundColor
        sectionsToolbar.editorDelegate = self
        undoRedoToolbar.editorDelegate = self
        setupContainerView()
        connectViews()
    }
}

private extension EditorViewController {
    var backgroundColor: UIColor {
        return UIColor(white: 31 / 255, alpha: 1)
    }

    func setupContainerView() {
        containerView.backgroundColor = backgroundColor
    }

    func connectViews() {
        connectSectionsToolbar()
        connectUndoRedoToolbar()
        connectPreview()
    }

    func connectSectionsToolbar() {
        view.fill(with: sectionsToolbar, connectingEdges: [.bottom], withSafeAreaRespecting: true)
        view.fill(with: sectionsToolbar, connectingEdges: [.left, .right], withSafeAreaRespecting: false)
        sectionsToolbar.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    func connectUndoRedoToolbar() {
        containerView.fill(with: undoRedoToolbar, connectingEdges: [.top], withSafeAreaRespecting: true)
        containerView.fill(with: undoRedoToolbar, connectingEdges: [.left, .right], withSafeAreaRespecting: false)
        undoRedoToolbar.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    func connectPreview() {
        view.fill(with: containerView, connectingEdges: [.left, .right], withSafeAreaRespecting: false)
        view.fill(with: containerView, connectingEdges: [.top], withSafeAreaRespecting: true)
        //preview.topAnchor.constraint(equalTo: undoRedoToolbar.bottomAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: sectionsToolbar.topAnchor).isActive = true
    }
}
