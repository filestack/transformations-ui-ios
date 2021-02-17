//
//  TextRenderNode.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 07/01/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

class TextRenderNode: RenderNode, RenderGroupChildNode & ObjectRenderNode & ViewableNode {
    weak var group: RenderGroupNode?

    var center: CGPoint = .zero {
        didSet { updatedCenter() }
    }

    var bounds: CGRect = .zero {
        didSet { updatedBounds() }
    }

    var transform: CGAffineTransform = .identity {
        didSet { updatedTransform() }
    }

    var opacity: CGFloat = 1 {
        didSet { updatedOpacity() }
    }

    var fontFamily: String = UIFont.systemFont(ofSize: UIFont.systemFontSize).familyName {
        didSet { updatedFont() }
    }

    var fontSize: CGFloat = UIFont.systemFontSize {
        didSet { updatedFontSize() }
    }

    var fontStyle: FontStyle = .none {
        didSet { updatedFont() }
    }

    var textColor: UIColor = .white {
        didSet { updatedTextColor() }
    }

    var textAlignment: NSTextAlignment = .left {
        didSet { updatedTextAlignment() }
    }

    var text: String = "" {
        didSet { updatedText() }
    }

    var isEditable: Bool = false {
        didSet { updatedIsEditable() }
    }

    var placeholder: String? {
        get { textView.placeholder }
        set { textView.placeholder = newValue }
    }

    var inputAccessoryView: UIView? {
        get { textView.inputAccessoryView }
        set { textView.inputAccessoryView = newValue }
    }

    private(set) lazy var view: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)

        return view
    }()

    // MARK: - Private Properties

    private lazy var autoScalingTextViewDelegate: AutoScalingTextViewDelegateForwarder = {
        let forwarder = AutoScalingTextViewDelegateForwarder()
        forwarder.delegate = self

        return forwarder
    }()

    private lazy var textView: AutoScalingTextView = {
        let textView = AutoScalingTextView()

        textView.shouldAutoUpdateFontSizeToMatchBounds = true
        textView.delegate = autoScalingTextViewDelegate
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isOpaque = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = .zero
        textView.isEditable = isEditable
        textView.isUserInteractionEnabled = isEditable
        textView.autocorrectionType = .no

        return textView
    }()
}

extension TextRenderNode: ChangeApplyingNode {
    @discardableResult
    func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }

    @discardableResult
    func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }

    func reloadInputViews() {
        textView.reloadInputViews()
    }

    func sizeToFit() {
        // Resize text view to fit content.
        textView.sizeToFit()

        // Calculate new center, taking the transform and text alignment into consideration.
        var invTCenter = center.applying(transform.inverted())

        switch textAlignment {
        case .justified:
            fallthrough
        case .left:
            invTCenter.x -= (bounds.size.width - textView.contentSize.width) / 2
        case .right:
            invTCenter.x += (bounds.size.width - textView.contentSize.width) / 2
        default:
            break
        }

        invTCenter.y -= (bounds.size.height - textView.contentSize.height) / 2

        // Update center.
        center = invTCenter.applying(transform)

        // Finally, update bounds based on new text view's content size.
        bounds.size = textView.contentSize
    }

    func apply(change: RenderNodeChange?, from node: RenderNode) {
        if let transform = change as? RenderNodeTransform {
            apply(transform: transform)
        }
    }
}

// MARK: - Private Functions

private extension TextRenderNode {
    func updatedCenter() {
        view.center = center
    }

    func updatedBounds() {
        view.bounds = bounds
        textView.frame = bounds
    }

    func updatedTransform() {
        view.transform = transform
    }

    func updatedText() {
        textView.text = text
        updateUnderlineStyle()
    }

    func updatedTextAlignment() {
        textView.textAlignment = textAlignment
    }

    func updatedTextColor() {
        textView.textColor = textColor
        textView.tintColor = textColor
        textView.tintColorDidChange()

        let mutableAttributedText = mutableAttributedTextCopy()
        let range = NSRange(location: 0, length: mutableAttributedText.length)

        mutableAttributedText.removeAttribute(.underlineColor, range: range)
        mutableAttributedText.addAttribute(.underlineColor, value: textColor, range: range)

        textView.attributedText = mutableAttributedText
    }

    func updatedFontSize() {
        guard let font = textView.font, font.pointSize != fontSize else { return }

        textView.font = UIFont(descriptor: font.fontDescriptor, size: fontSize)
    }

    func updatedFont() {
        // Set font, including font traits
        var fontTraits: UIFontDescriptor.SymbolicTraits = []

        if fontStyle.contains(.bold) {
            fontTraits.insert(.traitBold)
        }

        if fontStyle.contains(.italic) {
            fontTraits.insert(.traitItalic)
        }

        let fontDescriptor = UIFontDescriptor(fontAttributes: [
            .family : fontFamily,
            .traits: [UIFontDescriptor.TraitKey.symbolic: fontTraits.rawValue]
        ])

        let font = UIFont(descriptor: fontDescriptor, size: fontSize)

        textView.font = font

        updateUnderlineStyle()
    }

    func updateUnderlineStyle() {
        // Set underline style
        let mutableAttributedText = mutableAttributedTextCopy()
        let range = NSRange(location: 0, length: mutableAttributedText.length)

        mutableAttributedText.removeAttribute(.underlineStyle, range: range)

        if fontStyle.contains(.underline) {
            mutableAttributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }

        textView.attributedText = mutableAttributedText
    }

    func updatedIsEditable() {
        textView.isEditable = isEditable
        textView.isUserInteractionEnabled = isEditable
    }

    func updatedOpacity() {
        textView.alpha = opacity
    }

    func mutableAttributedTextCopy() -> NSMutableAttributedString {
        return textView.attributedText.mutableCopy() as! NSMutableAttributedString
    }
}

// MARK: - UITextViewDelegate Implementation

extension TextRenderNode: SwiftAutoScalingTextViewDelegate {
    @inline(__always) func textViewDidChange(_ textView: UITextView) {
        // Assign new text based on text view's text.
        text = textView.text

        // Notify change.
        group?.nodeFinishedChanging(node: self, change: nil)
    }

    @inline(__always) func textViewFontDidChange(_ textView: AutoScalingTextView) {
        guard let font = textView.font else { return }

        // Update `fontSize`.
        fontSize = font.pointSize
    }
}

// MARK: - Snapshotable Protocol Implementation

extension TextRenderNode: Snapshotable {
    public func snapshot() -> Snapshot {
        return [
            "center": center,
            "bounds": bounds,
            "transform": transform,
            "opacity": opacity,
            "textColor": textColor,
            "textAlignment": textAlignment,
            "fontFamily": fontFamily,
            "fontStyle": fontStyle,
            "fontSize": fontSize,
            "placeholder": placeholder,
            "text": text
        ]
    }

    func restore(from snapshot: Snapshot) {
        textView.shouldAutoUpdateFontSizeToMatchBounds = false

        if let center = snapshot["center"] as? CGPoint {
            self.center = center
        }

        if let bounds = snapshot["bounds"] as? CGRect {
            self.bounds = bounds
        }

        if let transform = snapshot["transform"] as? CGAffineTransform {
            self.transform = transform
        }

        if let opacity = snapshot["opacity"] as? CGFloat {
            self.opacity = opacity
        }

        if let textColor = snapshot["textColor"] as? UIColor {
            self.textColor = textColor
        }

        if let textAlignment = snapshot["textAlignment"] as? NSTextAlignment {
            self.textAlignment = textAlignment
        }

        if let fontFamily = snapshot["fontFamily"] as? String {
            self.fontFamily = fontFamily
        }

        if let fontStyle = snapshot["fontStyle"] as? FontStyle {
            self.fontStyle = fontStyle
        }

        if let fontSize = snapshot["fontSize"] as? CGFloat {
            self.fontSize = fontSize
        }

        if let placeholder = snapshot["placeholder"] as? String {
            self.placeholder = placeholder
        }

        if let text = snapshot["text"] as? String {
            self.text = text
        }

        textView.shouldAutoUpdateFontSizeToMatchBounds = true
    }
}
