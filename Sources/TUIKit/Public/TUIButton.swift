//
//  TUIButton.swift
//  TUIKit
//
//  Created by Ruben Nine on 22/10/21.
//

import UIKit

extension UIButton.State: Hashable {}

public final class TUIButton: UIButton {
    // MARK: - Public Properties

    public var group: Group? {
        didSet {
            if let group = oldValue {
                group.buttons.removeAll()
            }

            if let group = group {
                group.buttons.insert(WeakContainer<TUIButton>(object: self))
            }
        }
    }

    public override var isSelected: Bool {
        didSet {
            updateStateColors()
            updateGroupButtons()
        }
    }

    // MARK: - Private Properties

    private var config = UIConfig() {
        didSet {
            titleLabel?.font = config.font ?? .systemFont(ofSize: UIFont.smallSystemFontSize)

            for (k, v) in config.states {
                setTitleColor(v.tintColor, for: k)
            }

            layoutSubviews()
        }
    }

    // MARK: - Lifecycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

// MARK: - Public Functions

public extension TUIButton {
    @discardableResult
    func apply(config: UIConfig) -> Self {
        self.config = config

        return self
    }
}

// MARK: - Overrides

public extension TUIButton {
    override func layoutSubviews() {
        super.layoutSubviews()

        switch config.cornerMode {
        case .none:
            layer.cornerRadius = 0
            imageView?.layer.cornerRadius = 0
        case let .round(radius):
            layer.cornerRadius = radius
            imageView?.layer.cornerRadius = 0
        case let .roundImage(radius: radius):
            layer.cornerRadius = 0
            imageView?.layer.cornerRadius = radius
        }

        updateStateColors()
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let superRect = super.titleRect(forContentRect: contentRect)

        return CGRect(
            x: 0,
            y: superRect.minY + imagePadding(forContentRect: contentRect),
            width: contentRect.width,
            height: superRect.height
        )
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let proposedSize = imageSize(forContentRect: contentRect)
        let titleSize = titleRect(forContentRect: contentRect).size

        return CGRect(
            x: contentRect.width / 2 - proposedSize.width / 2,
            y: (contentRect.height - titleSize.height) / 2 - proposedSize.height / 2,
            width: proposedSize.width,
            height: proposedSize.height
        )
    }

    override var intrinsicContentSize: CGSize {
        _ = super.intrinsicContentSize

        guard let image = imageView?.image else { return super.intrinsicContentSize }

        let imageSize = config.imageSize ?? image.size
        let size = titleLabel?.sizeThatFits(contentRect(forBounds: bounds).size) ?? .zero
        let spacing = title(for: state) != nil ? config.spacing : 0

        let contentWidth = max(size.width, imageSize.width) + config.insets.left + config.insets.right
        let contentHeight = imageSize.height + size.height + config.insets.top + config.insets.bottom + spacing

        return CGSize(width: max(contentWidth, config.minButtonSize?.width ?? 0),
                      height: max(contentHeight, config.minButtonSize?.height ?? 0))
    }
}

// MARK: - CustomButton.UIConfig

public extension TUIButton {
    struct UIConfig {
        public let spacing: CGFloat
        public let insets: UIEdgeInsets
        public let cornerMode: CornerMode
        public let font: UIFont?
        public let imageSize: CGSize?
        public let minButtonSize: CGSize?
        public let states: [UIButton.State: StateConfig]

        public init(spacing: CGFloat = 6,
                    insets: UIEdgeInsets = .zero,
                    cornerMode: CornerMode = .none,
                    font: UIFont? = nil,
                    imageSize: CGSize? = nil,
                    minButtonSize: CGSize? = nil,
                    states: [State: StateConfig] = [:]) {
            self.spacing = spacing
            self.insets = insets
            self.cornerMode = cornerMode
            self.font = font
            self.imageSize = imageSize
            self.minButtonSize = minButtonSize
            self.states = states
        }
    }
}

public extension TUIButton.UIConfig {
    // MARK: - CustomButton.UIConfig.CornerMode

    enum CornerMode {
        case none
        case round(radius: CGFloat)
        case roundImage(radius: CGFloat)
    }

    // MARK: - CustomButton.UIConfig.StateConfig

    struct StateConfig {
        public var backgroundColor: UIColor?
        public var tintColor: UIColor?
        public var imageTintColor: UIColor?
        public var highlightColor: UIColor?
        public var alpha: CGFloat

        public init(backgroundColor: UIColor? = nil,
                    tintColor: UIColor? = nil,
                    imageTintColor: UIColor? = nil,
                    highlightColor: UIColor? = nil,
                    alpha: CGFloat = 1.0) {
            self.backgroundColor = backgroundColor
            self.tintColor = tintColor
            self.imageTintColor = imageTintColor
            self.highlightColor = highlightColor
            self.alpha = alpha
        }
    }
}

// MARK: - CustomButton.Group

public extension TUIButton {
    class Group {
        fileprivate var buttons = Set<WeakContainer<TUIButton>>()

        public init() {}
    }
}

// MARK: - Private Functions

private extension TUIButton {
    func setup() {
        layer.masksToBounds = true
        titleLabel?.textAlignment = .center
    }

    func updateStateColors() {
        guard let stateConfig = config.states[state] else { return }

        backgroundColor = stateConfig.backgroundColor
        tintColor = stateConfig.tintColor ?? super.tintColor
        imageView?.tintColor = stateConfig.imageTintColor ?? tintColor
        alpha = stateConfig.alpha
        isUserInteractionEnabled = !isSelected
    }

    func updateGroupButtons() {
        guard let buttons = group?.buttons, isSelected else { return }

        let otherButtons = (buttons.filter { $0.get() != self })

        // Turn off any other buttons in the group, only one should be active at a time.
        for button in otherButtons {
            if button.get()?.isSelected == true {
                button.get()?.isSelected = false
            }
        }
    }

    func imageSize(forContentRect contentRect: CGRect) -> CGSize {
        return config.imageSize ?? super.imageRect(forContentRect: contentRect).size
    }

    func imagePadding(forContentRect contentRect: CGRect) -> CGFloat {
        guard let _ = image(for: state), let _ = title(for: state) else { return 0 }

        return (imageSize(forContentRect: contentRect).height / 2) + config.spacing
    }
}
