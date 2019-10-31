//
//  UndoRedoToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 30/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

class UndoRedoToolbar: EditorToolbar {
    init() {
        super.init(frame: .infinite)
        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setActions(showUndo: Bool, showRedo: Bool) {
        var items = [space]

        if showUndo { items.append(undo) }
        if showRedo { items.append(redo) }

        setItems(items, animated: false)
    }
}

private extension UndoRedoToolbar {
    func setupView() {
        setActions(showUndo: false, showRedo: false)
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        barTintColor = .clear
        backgroundColor = .clear
    }
}
