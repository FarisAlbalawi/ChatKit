//
//  TypingBubble.swift
//  chatUI
//
//  Created by Faris Albalawi on 7/15/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit


open class TypingBubbleView: UIView {
    open var styles = ChatKit.Styles
    
    var displayName: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .left
        lab.text = "Faris is Typing..."
        lab.font = UIFont.italicSystemFont(ofSize: 12)
        return lab
    }()
    
    // MARK: - Subviews

     public var insets = UIEdgeInsets(top: 5, left: 15, bottom: 30, right: 0)
     
     public let typingBubble = TypingBubble()
     
     // MARK: - Initialization
     
     public override init(frame: CGRect) {
         super.init(frame: frame)
         setupSubviews()
     }
     
     required public init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         setupSubviews()
     }
     
     open func setupSubviews() {
         self.backgroundColor = .clear
         addSubview(displayName)
         addSubview(typingBubble)
         displayName.anchor(left: leftAnchor,bottom:bottomAnchor,paddingLeft: 15,paddingBottom: 5)
        
     }
     
     
     // MARK: - Layout
     
     open override func layoutSubviews() {
         super.layoutSubviews()
        
         typingBubble.frame = bounds.inset(by: insets)
     }
    
    func labelThatFits(_ title: String) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleLabel.widthAnchor.constraint(equalToConstant: titleLabel.intrinsicContentSize.width + 10).isActive = true
        return titleLabel
    }
    
}


/// A subclass of `UIView` that mimics the iMessage typing bubble
open class TypingBubble: UIView {
    
    // MARK: - Properties
    
    open var styles = ChatKit.Styles
    
    open var isPulseEnabled: Bool = true
    
    public private(set) var isAnimating: Bool = false
    
    open override var backgroundColor: UIColor? {
        set {
            [contentBubble, cornerBubble, tinyBubble].forEach { $0.backgroundColor = newValue }
        }
        get {
            return contentBubble.backgroundColor
        }
    }
    
    private struct AnimationKeys {
        static let pulse = "typingBubble.pulse"
    }
    
    // MARK: - Subviews
    
    /// The indicator used to display the typing animation.
    public let typingIndicator = TypingIndicator()
    
    public let contentBubble = UIView()
    
    public let cornerBubble = BubbleCircle()
    
    public let tinyBubble = BubbleCircle()
    
    // MARK: - Animation Layers
    
    open var contentPulseAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1
        animation.toValue = 1.04
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }
    
    open var circlePulseAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1
        animation.toValue = 1.1
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    open func setupSubviews() {
        addSubview(tinyBubble)
        addSubview(cornerBubble)
        addSubview(contentBubble)
        contentBubble.addSubview(typingIndicator)
        backgroundColor = styles.incomingBubbleColor
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
    
        let ratio = bounds.width / bounds.height
        let extraRightInset = bounds.width - 1.65/ratio*bounds.width
        
        let tinyBubbleRadius: CGFloat = bounds.height / 6
        tinyBubble.frame = CGRect(x: 0,
                                  y: bounds.height - tinyBubbleRadius,
                                  width: tinyBubbleRadius,
                                  height: tinyBubbleRadius)
        
        let cornerBubbleRadius = tinyBubbleRadius * 2
        let offset: CGFloat = tinyBubbleRadius / 6
        cornerBubble.frame = CGRect(x: tinyBubbleRadius - offset,
                                    y: bounds.height - (1.5 * cornerBubbleRadius) + offset,
                                    width: cornerBubbleRadius,
                                    height: cornerBubbleRadius)
        
        let contentBubbleFrame = CGRect(x: tinyBubbleRadius + offset,
                              y: 0,
                              width: bounds.width - (tinyBubbleRadius + offset) - extraRightInset,
                              height: bounds.height - (tinyBubbleRadius + offset))
        let contentBubbleFrameCornerRadius = contentBubbleFrame.height / 2
        
        contentBubble.frame = contentBubbleFrame
        contentBubble.layer.cornerRadius = contentBubbleFrameCornerRadius
            
        let insets = UIEdgeInsets(top: offset, left: contentBubbleFrameCornerRadius / 1.25, bottom: offset, right: contentBubbleFrameCornerRadius / 1.25)
        typingIndicator.frame = contentBubble.bounds.inset(by: insets)
    }
    
    // MARK: - Animation API
    
    open func startAnimating() {
        defer { isAnimating = true }
        guard !isAnimating else { return }
        typingIndicator.startAnimating()
        if isPulseEnabled {
            contentBubble.layer.add(contentPulseAnimationLayer, forKey: AnimationKeys.pulse)
            [cornerBubble, tinyBubble].forEach { $0.layer.add(circlePulseAnimationLayer, forKey: AnimationKeys.pulse) }
        }
    }
    
    open func stopAnimating() {
        defer { isAnimating = false }
        guard isAnimating else { return }
        typingIndicator.stopAnimating()
        [contentBubble, cornerBubble, tinyBubble].forEach { $0.layer.removeAnimation(forKey: AnimationKeys.pulse) }
    }
    
}

/// A `UIView` subclass that holds 3 dots which can be animated
open class TypingIndicator: UIView {
    
    // MARK: - Properties
    
    /// The offset that each dot will transform by during the bounce animation
    public var bounceOffset: CGFloat = 2.5
    
    /// A convenience accessor for the `backgroundColor` of each dot
    open var dotColor: UIColor = UIColor.systemGray {
        didSet {
            dots.forEach { $0.backgroundColor = dotColor }
        }
    }
    
    /// A flag that determines if the bounce animation is added in `startAnimating()`
    public var isBounceEnabled: Bool = false
    
    /// A flag that determines if the opacity animation is added in `startAnimating()`
    public var isFadeEnabled: Bool = true
    
    /// A flag indicating the animation state
    public private(set) var isAnimating: Bool = false
    
    /// Keys for each animation layer
    private struct AnimationKeys {
        static let offset = "typingIndicator.offset"
        static let bounce = "typingIndicator.bounce"
        static let opacity = "typingIndicator.opacity"
    }
    
    /// The `CABasicAnimation` applied when `isBounceEnabled` is TRUE to move the dot to the correct
    /// initial offset
    open var initialOffsetAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.byValue = -bounceOffset
        animation.duration = 0.5
        animation.isRemovedOnCompletion = true
        return animation
    }
    
    /// The `CABasicAnimation` applied when `isBounceEnabled` is TRUE
    open var bounceAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.toValue = -bounceOffset
        animation.fromValue = bounceOffset
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }
    
    /// The `CABasicAnimation` applied when `isFadeEnabled` is TRUE
    open var opacityAnimationLayer: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0.5
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }
    
    // MARK: - Subviews
    
    public let stackView = UIStackView()
    
    public let dots: [BubbleCircle] = {
        return [BubbleCircle(), BubbleCircle(), BubbleCircle()]
    }()
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    /// Sets up the view
    private func setupView() {
        dots.forEach {
            $0.backgroundColor = dotColor
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor).isActive = true
            stackView.addArrangedSubview($0)
        }
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        addSubview(stackView)
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        stackView.frame = bounds
        stackView.spacing = bounds.width > 0 ? 5 : 0
    }
    
    // MARK: - Animation API
    
    /// Sets the state of the `TypingIndicator` to animating and applies animation layers
    open func startAnimating() {
        defer { isAnimating = true }
        guard !isAnimating else { return }
        var delay: TimeInterval = 0
        for dot in dots {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let `self` = self else { return }
                if self.isBounceEnabled {
                    dot.layer.add(self.initialOffsetAnimationLayer, forKey: AnimationKeys.offset)
                    let bounceLayer = self.bounceAnimationLayer
                    bounceLayer.timeOffset = delay + 0.33
                    dot.layer.add(bounceLayer, forKey: AnimationKeys.bounce)
                }
                if self.isFadeEnabled {
                    dot.layer.add(self.opacityAnimationLayer, forKey: AnimationKeys.opacity)
                }
            }
            delay += 0.33
        }
    }
    
    /// Sets the state of the `TypingIndicator` to not animating and removes animation layers
    open func stopAnimating() {
        defer { isAnimating = false }
        guard isAnimating else { return }
        dots.forEach {
            $0.layer.removeAnimation(forKey: AnimationKeys.bounce)
            $0.layer.removeAnimation(forKey: AnimationKeys.opacity)
        }
    }
    
}

open class BubbleCircle: UIView {
    
    /// Lays out subviews and applys a circular mask to the layer
    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.mask = roundedMask(corners: .allCorners, radius: bounds.height / 2)
    }
    
    /// Returns a rounded mask of the view
    ///
    /// - Parameters:
    ///   - corners: The corners to round
    ///   - radius: The radius of curve
    /// - Returns: A mask
    open func roundedMask(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        return mask
    }
    
}
