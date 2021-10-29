//
//  SwiftMessagesCenteredSegue.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 28/10/21.
//  Copyright © 2021 Filestack. All rights reserved.
//

import UIKit
import SwiftMessages

class SwiftMessagesCenteredSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .centered)
        dimMode = .blur(style: .dark, alpha: 0.9, interactive: true)
        messageView.configureDropShadow()
    }
}
