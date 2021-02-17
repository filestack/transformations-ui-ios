//
//  AutoScalingTextViewDelegateForwarder.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 7/12/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

protocol SwiftAutoScalingTextViewDelegate: class {
    func textViewDidChange(_ textView: UITextView)
    func textViewFontDidChange(_ textView: AutoScalingTextView)
}

class AutoScalingTextViewDelegateForwarder: NSObject, AutoScalingTextViewDelegate {
    weak var delegate: SwiftAutoScalingTextViewDelegate?

    func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChange(textView)
    }

    func textViewFontDidChange(_ textView: AutoScalingTextView) {
        delegate?.textViewFontDidChange(textView)
    }
}
