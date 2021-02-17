//
//  ColorPickerViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 13/02/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import Pikko

class ColorPickerViewController: UIViewController {
    typealias SelectionHandler = (UIColor) -> Void

    private let pikko: Pikko
    private let onSelect: SelectionHandler?
    private let color: UIColor

    // MARK: - Lifecycle

    init(color: UIColor? = nil, dimension: CGFloat, onSelect: SelectionHandler? = nil) {
        self.color = color ?? .white
        self.pikko = Pikko(dimension: Int(dimension))
        self.onSelect = onSelect

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        pikko.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(pikko)

        pikko.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pikko.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        pikko.delegate = self
        pikko.setColor(color)

        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)

        pikko.delegate = nil
    }
}

extension ColorPickerViewController: PikkoDelegate {
    func writeBackColor(color: UIColor) {
        onSelect?(color)
    }
}
