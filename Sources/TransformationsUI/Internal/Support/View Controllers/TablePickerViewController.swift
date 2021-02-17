//
//  TablePickerViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 13/02/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//
//  Based on https://www.ralfebert.de/ios-examples/uikit/choicepopover/

import UIKit

class TablePickerViewController<Element> : UITableViewController {
    typealias SelectionHandler = (Element) -> Void
    typealias LabelProvider = (Element) -> String

    private let values: [Element]
    private let labels: LabelProvider
    private let header: String?
    private let onSelect: SelectionHandler?
    private let selectedIndex: Int?

    // MARK: - Lifecycle

    init(_ values: [Element],
         selectedIndex: Int? = nil,
         labels: @escaping LabelProvider = String.init(describing:),
         header: String? = nil,
         onSelect: SelectionHandler? = nil) {
        self.values = values
        self.onSelect = onSelect
        self.labels = labels
        self.header = header
        self.selectedIndex = selectedIndex

        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Overrides

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndex = selectedIndex {
            tableView.selectRow(at: [0, selectedIndex], animated: false, scrollPosition: .top)
        }
    }

    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return header
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = labels(values[indexPath.row])

        return cell
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true)

        onSelect?(values[indexPath.row])
    }
}
