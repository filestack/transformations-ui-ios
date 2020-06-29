//
//  EditorUndoManager.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation
import TransformationsUIShared

protocol EditorUndoManagerDelegate: class {
    func undoManagerChanged(editorUndoManager: EditorUndoManager)
}

class EditorUndoManager {
    typealias UndoStep = Snapshot

    // MARK: - Internal Properties

    weak var delegate: EditorUndoManagerDelegate?

    var currentStep: UndoStep {
        return undoStack.last ?? initialStep
    }

    // MARK: - Private Properties

    private let initialStep: UndoStep
    private var undoStack: [UndoStep] = []
    private var redoStack: [UndoStep] = []

    // MARK: - Lifecycle

    /// Initializes the `EditorUndoManager` with a initial `UndoStep`.
    /// - Parameter initialStep: The `UndoStep` to use as the initial step.
    required init(initialStep: UndoStep) {
        self.initialStep = initialStep
    }
}

// MARK: - Internal Functions

extension EditorUndoManager {
    /// Registers an undo step, optionally marking it as `transitory`.
    ///
    /// - Parameters:
    ///   - step: The `UndoStep` to register in the stack.
    ///   - transitory: Whether the step is transitory (not persistent). Defaults to `false.`
    ///
    /// Transitory steps are always replaced by any newly added steps.
    func register(step: UndoStep, transitory: Bool = false) {
        undoStack.removeAll { $0.isTransitory }
        undoStack.append(transitory ? step.asTransitory() : step)
        redoStack.removeAll()

        DispatchQueue.main.async {
            self.delegate?.undoManagerChanged(editorUndoManager: self)
        }
    }

    /// Explicitely removes any transitory undo steps currently in the stack.
    func removeTransitorySteps() {
        undoStack.removeAll { $0.isTransitory }

        DispatchQueue.main.async {
            self.delegate?.undoManagerChanged(editorUndoManager: self)
        }
    }

    /// Removes the last step from the undo stack and pushes it into the redo stack.
    func undo() {
        if canUndo() {
            redoStack.append(undoStack.removeLast())

            DispatchQueue.main.async {
                self.delegate?.undoManagerChanged(editorUndoManager: self)
            }
        }
    }

    /// Removes the last step from the redo stack and pushes it into the undo stack.
    func redo() {
        if canRedo() {
            undoStack.append(redoStack.removeLast())

            DispatchQueue.main.async {
                self.delegate?.undoManagerChanged(editorUndoManager: self)
            }
        }
    }

    /// Returns whether the undo manager contains any steps in the undo stack.
    /// - Returns: `true` if it can undo, `false` otherwise.
    func canUndo() -> Bool {
        return !undoStack.isEmpty
    }

    /// Returns whether the undo manager contains any steps in the redo stack.
    /// - Returns: `true` if it can redo, `false` otherwise.
    func canRedo() -> Bool {
        return !redoStack.isEmpty
    }
}

// MARK: - Misc UndoStep Extensions

private extension EditorUndoManager.UndoStep {
    var isTransitory: Bool {
        set { self["isTransitory"] = newValue }
        get { self["isTransitory"] as? Bool == true }
    }

    /// Returns a transitory copy of itself.
    func asTransitory() -> Self {
        var transitoryCopy = self
        transitoryCopy.isTransitory = true

        return transitoryCopy
    }
}
