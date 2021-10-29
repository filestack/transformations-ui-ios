//
//  StickersPickerViewController.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 14/12/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

class CollectionViewFlowLayout: UICollectionViewFlowLayout {
    /// The default implementation of this method returns false.
    /// Subclasses can override it and return an appropriate value
    /// based on whether changes in the bounds of the collection
    /// view require changes to the layout of cells and supplementary views.
    /// If the bounds of the collection view change and this method returns true,
    /// the collection view invalidates the layout by calling the invalidateLayout(with:) method.
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return (self.collectionView?.bounds ?? newBounds) == newBounds
    }
}

protocol StickersPickerViewControllerDelegate: AnyObject {
    func stickersPickerViewControllerDismissed(with image: UIImage?, in section: String?)
}

class StickersPickerViewController: UICollectionViewController {
    // MARK: - Internal Properties

    weak var delegate: StickersPickerViewControllerDelegate?

    var elements: [String: [UIImage]] = [:] {
        didSet { sections = elements.keys.sorted() }
    }

    var selectedElement: UIImage? = nil {
        didSet { shouldScrollToElement = selectedElement != nil && selectedSection != nil }
    }

    var selectedSection: String? = nil {
        didSet { shouldScrollToElement = selectedElement != nil && selectedSection != nil }
    }

    // MARK: - Private Properties

    private var sections: [String] = []
    private var shouldScrollToElement: Bool = false

    init() {
        super.init(collectionViewLayout: CollectionViewFlowLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if elements.isEmpty {
            let header = UILabel()

            header.translatesAutoresizingMaskIntoConstraints = false
            header.font = Constants.Fonts.default(ofSize: UIFont.labelFontSize)
            header.text = "No stickers provided."
            header.textAlignment = .center
            header.backgroundColor = Constants.Color.tertiaryBackground

            view.addSubview(header)
            header.snp.makeConstraints { $0.edges.equalTo(view) }

            UIView.transition(from: collectionView, to: header, duration: 0.5, options: .transitionCrossDissolve) { completed in
                self.collectionView.isHidden = true
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if shouldScrollToElement {
            shouldScrollToElement = false

            guard let section = selectedSection else { return }
            guard let index = (elements[section]?.firstIndex { $0 == selectedElement }) else { return }
            guard let sectionIndex = (sections.firstIndex { $0 == section }) else { return }

            let path = IndexPath(item: index, section: sectionIndex)

            collectionView.scrollToItem(at: path, at: .top, animated: true)
        }
    }

    // MARK: - Actions

    @objc func cancelSelected(sender: UIButton) {
        selectedElement = nil
        dismiss(animated: true)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: true, completion: completion)
        delegate?.stickersPickerViewControllerDismissed(with: selectedElement, in: selectedSection)
    }
}

class StickerViewCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill

        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let insets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)

        backgroundView = UIView()

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalTo(contentView).inset(insets) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundView?.layer.cornerRadius = 5
                backgroundView?.layer.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2).cgColor
            } else {
                backgroundView?.layer.backgroundColor = nil
            }
        }
    }
}

class SectionHeader: UICollectionReusableView {
    let sectionHeaderlabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.Fonts.default(ofSize: UIFont.labelFontSize)

        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        if sectionHeaderlabel.superview == nil {
            addSubview(sectionHeaderlabel)
            sectionHeaderlabel.snp.makeConstraints { $0.edges.equalTo(self) }
        }
    }
}

extension StickersPickerViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elements[sections[section]]!.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerViewCell", for: indexPath) as? StickerViewCell
        else {
            fatalError("StickerViewCell is not registered.")
        }

        if let element = elements[sections[indexPath.section]]?[indexPath.row] {
            cell.imageView.image = element
            cell.isSelected = selectedElement == element
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let element = elements[sections[indexPath.section]]?[indexPath.row] else { return }

        selectedElement = element
        selectedSection = sections[indexPath.section]

        dismiss(animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader
        else {
            fatalError("SectionHeader is not registered")
        }

        sectionHeader.sectionHeaderlabel.text = sections[indexPath.section]

        return sectionHeader
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: UIFont.labelFontSize * 2)
    }
}

extension StickersPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellSpacing, left: cellSpacing, bottom: cellSpacing, right: cellSpacing)
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt _: IndexPath) -> CGSize {
        return cellSize
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return cellSpacing
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return cellSpacing
    }
}

private extension StickersPickerViewController {
    var cellSize: CGSize {
        return CGSize(width: cellSide, height: cellSide)
    }

    var cellSide: CGFloat {
        let totalSpacing = cellSpacing * (columnsCount + 1)
        return (totalWidth - totalSpacing) / columnsCount
    }

    var totalWidth: CGFloat {
        return view.safeAreaLayoutGuide.layoutFrame.width
    }

    var columnsCount: CGFloat {
        return (totalWidth / targetSide).rounded(.down)
    }

    var targetSide: CGFloat {
        return 100.0
    }

    var cellSpacing: CGFloat {
        return 6
    }

    var contentInset: UIEdgeInsets {
        UIEdgeInsets(top: 22, left: 22, bottom: 22, right: 22)
    }
}

private extension StickersPickerViewController {
    func setup() {
        setupNavigationItems()
        setupViews()
    }

    func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancelSelected))
    }

    func setupViews() {
        collectionView.backgroundColor = Constants.Color.background

        collectionView?.register(StickerViewCell.self, forCellWithReuseIdentifier: "StickerViewCell")
        collectionView?.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")

        collectionView?.contentInsetAdjustmentBehavior = .always
        collectionView?.contentInset = contentInset
    }
}
