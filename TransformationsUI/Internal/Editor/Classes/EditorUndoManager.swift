//
//  EditorUndoManager.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

protocol EditorUndoManagerDelegate: class {
    func undoManagerChanged(editorUndoManager: EditorUndoManager)
}

class EditorUndoManager {
    weak var delegate: EditorUndoManagerDelegate?

    typealias State = Snapshot

    private let initialState: State
    private var undoStack: [State] = []
    private var redoStack: [State] = []

    var current: State {
        return undoStack.last ?? initialState
    }

    init(state: State) {
        self.initialState = state
    }

    func register(step: State) {
        undoStack.append(step)

        DispatchQueue.main.async {
            self.delegate?.undoManagerChanged(editorUndoManager: self)
        }
    }

    // MARK: - Undo, Redo & Reset Commands

    func undo() {
        if canUndo() {
            redoStack.append(undoStack.removeLast())

            DispatchQueue.main.async {
                self.delegate?.undoManagerChanged(editorUndoManager: self)
            }
        }
    }

    func redo() {
        if canRedo() {
            undoStack.append(redoStack.removeLast())

            DispatchQueue.main.async {
                self.delegate?.undoManagerChanged(editorUndoManager: self)
            }
        }
    }

    func canUndo() -> Bool {
        return !undoStack.isEmpty
    }

    func canRedo() -> Bool {
        return !redoStack.isEmpty
    }
}

