//
//  ArrangeableViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 11/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

/// Adds the ability to define constraints based on pairs of `UIUserInterfaceSizeClass` traits.
open class ArrangeableViewController: UIViewController {
    private struct VariationPair: Hashable {
        var width: UIUserInterfaceSizeClass
        var height: UIUserInterfaceSizeClass
    }

    private var variations = [VariationPair: [NSLayoutConstraint]]()

    public func defineConstraints(width: UIUserInterfaceSizeClass, height: UIUserInterfaceSizeClass,
                                  constraints: () -> [NSLayoutConstraint]) {
        if variations[VariationPair(width: width, height: height)] == nil {
            variations[VariationPair(width: width, height: height)] = []
        }

        variations[VariationPair(width: width, height: height)]?.append(contentsOf: constraints())
    }
}

extension ArrangeableViewController {
    // All possible variations, from least specific, to the most specific.
    private var activeVariations: [[NSLayoutConstraint]] {
        return [
            variations[VariationPair(width: .unspecified, height: .unspecified)],
            variations[VariationPair(width: traitCollection.horizontalSizeClass, height: .unspecified)],
            variations[VariationPair(width: .unspecified, height: traitCollection.verticalSizeClass)],
            variations[VariationPair(width: traitCollection.horizontalSizeClass, height: traitCollection.verticalSizeClass)]
        ].compactMap { $0 }
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Deactivate all constraints before activating new ones to avoid conflicts.
        for (_, values) in variations {
            for constraint in values {
                constraint.isActive = false
            }
        }

        // Activate constraints that are part of any active variation.
        for variation in activeVariations {
            for constraint in variation {
                constraint.isActive = true
            }
        }
    }
}
