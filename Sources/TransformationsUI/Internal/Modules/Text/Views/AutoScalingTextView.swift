//
//  AutoScalingTextView.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 23/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

protocol AutoScalingTextViewDelegate: UITextViewDelegate {
    func textViewFontDidChange(_ textView: AutoScalingTextView)
}

extension AutoScalingTextViewDelegate {
    func textViewFontDidChange(_ textView: AutoScalingTextView) {}
}

class AutoScalingTextView: UITextView {
    // MARK: - Internal Properties

    override var delegate: UITextViewDelegate? {
        get { internalDelegate }
        set { internalDelegate = newValue as? AutoScalingTextViewDelegate }
    }

    override var frame: CGRect {
        didSet {
            guard shouldAutoUpdateFontSizeToMatchBounds else { return }
            guard oldValue.size != frame.size else { return }

            let oldAspectRatio = oldValue.size.width / oldValue.size.height
            let newAspectRatio = frame.size.width / frame.size.height
            let diff = (oldAspectRatio / newAspectRatio)

            if abs(1 - diff) < 0.0001 {
                // When the difference in aspect ratio is none or miniscule, we'll suggest a new scale
                // instead of letting `adjustFontSizeIfNeeded()` guess the new size.
                let scale = frame.size.width / oldValue.size.width
                adjustFontSizeIfNeeded(using: scale)
            } else {
                // Let `adjustFontSizeIfNeeded()` guess the new size.
                adjustFontSizeIfNeeded(using: nil, granularity: 0.02)
            }
        }
    }

    override var font: UIFont? {
        didSet {
            guard !pointSizeBeingAdjusted, oldValue != font else { return }

            internalDelegate?.textViewFontDidChange(self)
        }
    }

    override var attributedText: NSAttributedString! {
        didSet {
            if text.isEmpty, isFirstResponder {
                addPlaceholder()
            } else {
                removePlaceholder()
            }

            layoutIfNeeded()
            adjustFontSizeIfNeeded()
        }
    }

    override var textAlignment: NSTextAlignment {
        didSet {
            placeholderTextView?.textAlignment = textAlignment
        }
    }

    /// Placeholder to use when text is empty.
    var placeholder: String?

    /// Whether the font size should be automatically adjusted to better fill the current text view bounds.
    /// Defaults to `true`.
    var shouldAutoUpdateFontSizeToMatchBounds: Bool = true

    /// The minimum allowed point size to use when auto font size updating is enabled.
    var minimumAutoUpdateFontPointSize: CGFloat = UIFont.smallSystemFontSize

    // MARK: - Private Properties

    private weak var internalDelegate: AutoScalingTextViewDelegate?
    private var observers: [NSObjectProtocol] = []
    private var placeholderTextView: UITextView?
    private var pointSizeBeingAdjusted: Bool = false
}

// MARK: - Overrides

extension AutoScalingTextView {
    override func becomeFirstResponder() -> Bool {
        addObservers()

        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        removeObservers()

        return super.resignFirstResponder()
    }
}

// MARK: - Private Functions

private extension AutoScalingTextView {
    func addPlaceholder() {
        removePlaceholder()

        guard let placeholder = placeholder else { return }

        let placeholderTextView = UITextView()

        placeholderTextView.isOpaque = false
        placeholderTextView.backgroundColor = .clear

        if let font = font {
            placeholderTextView.font = UIFont(descriptor: font.fontDescriptor, size: minimumAutoUpdateFontPointSize)
        }

        placeholderTextView.textAlignment = textAlignment
        placeholderTextView.textColor = UIColor(white: 1, alpha: 0.3)
        placeholderTextView.text = placeholder
        placeholderTextView.frame = bounds
        placeholderTextView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        placeholderTextView.isEditable = false

        addSubview(placeholderTextView)

        self.placeholderTextView = placeholderTextView
    }

    func removePlaceholder() {
        placeholderTextView?.removeFromSuperview()
        placeholderTextView = nil
    }

    func addObservers() {
        guard superview != nil else { return }

        removeObservers()

        observers.append(NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification,
                                                                object: self,
                                                                queue: .main) { _ in
            self.adjustFontSizeIfNeeded()
        })

        observers.append(NotificationCenter.default.addObserver(forName: UITextView.textDidBeginEditingNotification,
                                                                object: self,
                                                                queue: .main) { _ in
            if self.text.isEmpty {
                self.addPlaceholder()
                self.layoutIfNeeded()
                self.adjustFontSizeIfNeeded()
            }
        })

        observers.append(NotificationCenter.default.addObserver(forName: UITextView.textDidEndEditingNotification,
                                                                object: self,
                                                                queue: .main) { _ in
            self.removePlaceholder()
        })
    }

    func removeObservers() {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }

        observers.removeAll()
    }

    /// Automatically adjusts font size based on content and bounds, or, when given a `scale`, scales up or down font
    /// based on given scaling factor.
    ///
    /// - Parameter scale: The scaling factor to apply.
    func adjustFontSizeIfNeeded(using scale: CGFloat? = nil, granularity: CGFloat = 0.25) {
        defer { pointSizeBeingAdjusted = false }
        pointSizeBeingAdjusted = true

        // If we have a `placeholderTextView`, we will apply new font sizes there first,
        // and finally update `self` using the same font size we applied to `placeholderTextView`.
        let textView = placeholderTextView ?? self

        // Ensure `textView` has a font.
        guard let originalFont = textView.font else { return }

        if let scale = scale {
            // When given a scale, we just apply it as it without any further calculations.
            let newPointSize = originalFont.pointSize * scale

            pointSizeBeingAdjusted = false

            // Apply `newPointSize`.
            textView.font = UIFont(descriptor: originalFont.fontDescriptor, size: newPointSize)
            textView.layoutManager.ensureLayout(for: textView.textContainer)

            // If `textView` is not `self`, let's update `font` as well.
            if textView != self {
                font = textView.font
                layoutManager.ensureLayout(for: textContainer)
            }

            return
        }

        // No new scale given, we must calculate a new optimal font size.

        guard !textView.text.isEmpty else { return }
        guard textView.contentSize.height != textView.bounds.height else { return }

        let shouldGrow = textView.contentSize.height < textView.bounds.height
        var bestMatchingSize = originalFont.pointSize

        // 1) Determine the best next larger or smaller font size that fits, depending on whether we should be
        // scaling up or down using some coarse granularity. We will refine our match on a later step.
        while true {
            guard let fontPointSize = textView.font?.pointSize else { break }

            if shouldGrow {
                // Try to find the next larger font size that fits.
                let pointSize = max(minimumAutoUpdateFontPointSize, fontPointSize * (1.0 + granularity))

                textView.font = UIFont(descriptor: originalFont.fontDescriptor, size: pointSize)
                textView.layoutManager.ensureLayout(for: textView.textContainer)

                if textView.contentSize.height >= textView.bounds.height {
                    break
                } else {
                    bestMatchingSize = pointSize
                }
            } else {
                // Try to find the next smaller font size that fits.
                let pointSize = max(minimumAutoUpdateFontPointSize, fontPointSize * (1.0 - granularity))

                textView.font = UIFont(descriptor: originalFont.fontDescriptor, size: pointSize)
                textView.layoutManager.ensureLayout(for: textView.textContainer)

                if textView.contentSize.height <= textView.bounds.height || pointSize == minimumAutoUpdateFontPointSize {
                    bestMatchingSize = pointSize
                    break
                }
            }
        }

        // Apply `bestMatchingSize`.
        textView.font = UIFont(descriptor: originalFont.fontDescriptor, size: bestMatchingSize)
        textView.layoutManager.ensureLayout(for: textView.textContainer)

        // 2) Refine the best match.
        var identicalCount = 0

        while true {
            guard let pointSize = textView.font?.pointSize, pointSize > minimumAutoUpdateFontPointSize else { break }

            let newPointSize = max(minimumAutoUpdateFontPointSize, (originalFont.pointSize + pointSize) / 2)

            textView.font = UIFont(descriptor: originalFont.fontDescriptor, size: newPointSize)
            textView.layoutManager.ensureLayout(for: textView.textContainer)

            if shouldGrow {
                if textView.contentSize.height <= textView.bounds.height { break }
            } else {
                if textView.contentSize.height >= textView.bounds.height { break }
            }

            if bestMatchingSize == newPointSize {
                identicalCount += 1
            } else {
                identicalCount = 0
            }

            if identicalCount > 2 { break }

            bestMatchingSize = newPointSize
        }

        pointSizeBeingAdjusted = false

        // Apply `bestMatchingSize`.
        textView.font = UIFont(descriptor: originalFont.fontDescriptor, size: bestMatchingSize)
        textView.layoutManager.ensureLayout(for: textView.textContainer)

        // Ensure there's no fragmented words.
        // Also, if `textView` equals `placeholderTextView` then ensure all words fit in one single fragment.
        while textView.areWordsFragmented(requireSingleFragment: textView == placeholderTextView) {
            guard let pointSize = textView.font?.pointSize, pointSize > minimumAutoUpdateFontPointSize else { break }

            let newPointSize = max(minimumAutoUpdateFontPointSize, pointSize * (1.0 - granularity))

            textView.font = UIFont(descriptor: originalFont.fontDescriptor, size: newPointSize)
            textView.layoutManager.ensureLayout(for: textView.textContainer)
        }

        // If `textView` is not `self`, let's update `font` as well.
        if textView != self {
            font = textView.font
            layoutManager.ensureLayout(for: textContainer)
        }
    }
}

private extension UITextView {
    // When `requireSingleFragment` is false, checks if there's at least one single word that is fragmented.
    // When `requireSingleFragment` is true, checks that all words belong to one single fragment.
    func areWordsFragmented(requireSingleFragment: Bool) -> Bool {
        if requireSingleFragment {
            return isRangeFragmented(range: NSRange(location: 0, length: text.count))
        }

        let words = text.split(separator: " ")
        var wordIndex: Int = 0

        for word in words {
            let range = NSRange(location: wordIndex, length: word.count)

            if isRangeFragmented(range: range) { return true }

            wordIndex += word.count + 1
        }

        return false
    }

    func isRangeFragmented(range: NSRange) -> Bool {
        var effectiveRange: NSRange = NSRange()

        layoutManager.lineFragmentRect(forGlyphAt: range.location, effectiveRange: &effectiveRange)

        return effectiveRange.intersection(range) != range
    }
}
