//
//  SegmentedControlToolbar.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 28/05/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import UberSegmentedControl

/// `SegmentedControlToolbar` is a special type of `StandardToolbar` that presents items inside a `UberSegmentedControl`.
public class SegmentedControlToolbar: StandardToolbar {
    // MARK: - Private Properties

    private let observers = NSMapTable<UberSegmentedControl, NSKeyValueObservation>(keyOptions: .weakMemory,
                                                                                    valueOptions: .strongMemory)

    private lazy var segmentedControl: UberSegmentedControl = {
        let control = UberSegmentedControl(items: nil)

        // Setup segmented control depending on item style.
        switch style.itemStyle.mode {
        case .both, .image:
            for (idx, item) in descriptibleItems.enumerated() {
                if let image = item.icon {
                    // Insert segment with image.
                    control.insertSegment(with: image, at: idx, animated: false)

                    if style.itemStyle.mode == .both {
                        // Set segment title also.
                        control.setTitle(item.title, forSegmentAt: idx)
                    } else {
                        image.accessibilityLabel = item.title
                    }
                } else {
                    control.insertSegment(withTitle: item.title, at: idx, animated: false)
                }
            }
        case .text:
            for (idx, title) in descriptibleItems.map(\.title).enumerated() {
                // Insert segment with title.
                control.insertSegment(withTitle: title, at: idx, animated: false)
            }
        }

        if control.numberOfSegments > 0 {
            // Select first segment.
            control.selectedSegmentIndexes = IndexSet([0])
        }

        // Add observer on `selectedSegmentIndexes`.
        observers.setObject(control.observe(\.selectedSegmentIndexes, options: [.new, .old]) { (control, change) in
            guard change.newValue != change.oldValue, let selectedIndex = change.newValue?.first else { return }

            let item = self.descriptibleItems[selectedIndex]

            self.delegate?.toolbarItemSelected(toolbar: self, item: item, control: control)
        }, forKey: control)

        return control
    }()

    // MARK: - Lifecycle

    public required init(items: [DescriptibleEditorItem], style: EditorToolbarStyle = .segments) {
        super.init(items: items, style: style)

        setItems([segmentedControl])
    }

    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        observers.removeAllObjects()
    }
}

// MARK: - Public Functions

public extension SegmentedControlToolbar {
    func resetSelectedSegment(to index: Int = 0) {
        segmentedControl.selectedSegmentIndexes = IndexSet([index])
    }
}
