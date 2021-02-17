//
//  TextViewController+ToolbarDelegate.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 10/02/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import UberSegmentedControl

extension TextController: TextToolbarDelegate {
    func textToolbarFontFamilyChanged(_ toolbar: TextToolbar) {
        guard let module = getModule() as? Module else { return }
        guard let control = toolbar.selectFontFamilyControl else { return }

        let selectedIndex = module.availableFontFamilies.firstIndex(of: toolbar.fontFamily ?? "")

        let controller = TablePickerViewController(module.availableFontFamilies,
                                                   selectedIndex: selectedIndex,
                                                   header: "Font Family") { (fontFamily) in
            toolbar.fontFamily = fontFamily
            self.renderNode.fontFamily = fontFamily
            self.renderNodeFinishedChanging()
        }

        controller.preferredContentSize = CGSize(width: 220, height: UIView.noIntrinsicMetric)
        showPopup(controller, sourceView: control)
    }

    func textToolbarFontColorChanged(_ toolbar: TextToolbar) {
        guard let control = toolbar.selectFontColorControl else { return }

        let dimension: CGFloat = 270

        let controller = ColorPickerViewController(color: toolbar.fontColor, dimension: dimension) { textColor in
            toolbar.fontColor = textColor
            self.renderNode.textColor = textColor
            self.renderNodeFinishedChanging()
        }

        controller.preferredContentSize = CGSize(width: dimension + 30, height: dimension + 30)
        showPopup(controller, sourceView: control)
    }

    func textToolbarFontStyleChanged(_ toolbar: TextToolbar) {
        if let fontStyle = toolbar.fontStyle {
            renderNode.fontStyle = fontStyle
        }

        renderNodeFinishedChanging()
    }

    func textToolbarTextAlignmentChanged(_ toolbar: TextToolbar) {
        if let textAlignment = toolbar.textAlignment {
            renderNode.textAlignment = textAlignment
        }

        renderNodeFinishedChanging()
    }
}

private extension TextController {
    func renderNodeFinishedChanging() {
        renderNode.group?.nodeFinishedChanging(node: renderNode, change: nil)
    }
}
