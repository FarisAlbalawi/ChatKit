//
//  ColorSlider.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/23/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

/// The orientation in which the `ColorSlider` is drawn.
public enum Orientation {
    /// The horizontal orientation.
    case horizontal
    
    /// The vertical orientation.
    case vertical
}

public class ColorSlider: UIControl {
    /// The selected color.
    public var color: UIColor {
        get {
            return UIColor(hsbColor: internalColor)
        }
        set {
            internalColor = HSBColor(color: newValue)
            
            previewView?.colorChanged(to: color)
            previewView?.transition(to: .inactive)
            
            sendActions(for: .valueChanged)
        }
    }
    
    /// The background gradient view.
    public let gradientView: GradientView
    
    /// The preview view, passed in the required initializer.
    public let previewView: PreviewView?
    
    /// The layout orientation of the slider, as defined in the required initializer.
    internal let orientation: Orientation
    
    /// The internal HSBColor representation of `color`.
    internal var internalColor: HSBColor

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) and storyboards are unsupported, use init(orientation:) instead.")
    }
    
    // MARK: - Init
    
    /// - parameter orientation: The orientation of the ColorSlider.
    /// - parameter side: The side of the ColorSlider on which to anchor the live preview.
    public convenience init(orientation: Orientation = .vertical, previewSide side: DefaultPreviewView.Side = .left) {
        // Check to ensure the side is valid for the given orientation
        switch orientation {
        case .horizontal:
            assert(side == .top || side == .bottom, "The preview must be on the top or bottom for orientation \(orientation).")
        case .vertical:
            assert(side == .left || side == .right, "The preview must be on the left or right for orientation \(orientation).")
        }
        
        // Create the preview view
        let previewView = DefaultPreviewView(side: side)
        self.init(orientation: orientation, previewView: previewView)
    }
    
    /// - parameter orientation: The orientation of the ColorSlider.
    /// - parameter previewView: An optional preview view that stays anchored to the slider. See ColorSliderPreviewing.
    required public init(orientation: Orientation, previewView: PreviewView?) {
        self.orientation = orientation
        self.previewView = previewView
        
        gradientView = GradientView(orientation: orientation)
        internalColor = HSBColor(hue: 0, saturation: gradientView.saturation, brightness: 1)
        
        super.init(frame: .zero)
        
        addSubview(gradientView)
        
        if let currentPreviewView = previewView {
            currentPreviewView.isUserInteractionEnabled = false
            addSubview(currentPreviewView)
        }
    }
}

/// :nodoc:
// MARK: - Layout
extension ColorSlider {
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientView.frame = bounds
        
        if let preview = previewView {
            switch orientation {
            
            // Initial layout pass, set preview center as needed
            case .horizontal where preview.center.y != bounds.midY,
                 .vertical where preview.center.x != bounds.midX:
                
                if internalColor.hue == 0 {
                    // Initially set preview center to the top or left
                    centerPreview(at: .zero)
                } else {
                    // Set preview center from `internalColor`
                    let sliderProgress = gradientView.calculateSliderProgress(for: internalColor)
                    centerPreview(at: CGPoint(x: sliderProgress * bounds.width, y: sliderProgress * bounds.height))
                }
                
            // Adjust preview view size if needed
            case .horizontal where autoresizesSubviews:
                preview.bounds.size = CGSize(width: 25, height: bounds.height + 10)
            case .vertical where autoresizesSubviews:
                preview.bounds.size = CGSize(width: bounds.width + 10, height: 25)
                
            default:
                break
            }
        }
    }
    
    /// Center the preview view at a particular point, given the orientation.
    ///
    /// * If orientation is `.horizontal`, the preview is centered at `(point.x, bounds.midY)`.
    /// * If orientation is `.vertical`, the preview is centered at `(bounds.midX, point.y)`.
    ///
    /// The `x` and `y` values of `point` are constrained to the bounds of the slider.
    /// - parameter point: The desired point at which to center the `previewView`.
    internal func centerPreview(at point: CGPoint) {
        switch orientation {
        case .horizontal:
            let boundedTouchX = (0..<bounds.width).clamp(point.x)
            previewView?.center = CGPoint(x: boundedTouchX, y: bounds.midY)
        case .vertical:
            let boundedTouchY = (0..<bounds.height).clamp(point.y)
            previewView?.center = CGPoint(x: bounds.midX, y: boundedTouchY)
        }
    }
}

/// :nodoc:
// MARK: - UIControlEvents
extension ColorSlider {
    /// Begins tracking a touch when the user starts dragging.
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        // Reset saturation to default value
        internalColor.saturation = gradientView.saturation

        update(touch: touch, touchInside: true)
        
        let touchLocation = touch.location(in: self)
        centerPreview(at: touchLocation)
        previewView?.transition(to: .active)
        
        sendActions(for: .touchDown)
        sendActions(for: .valueChanged)
        return true
    }
    
    /// Continues tracking a touch as the user drags.
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        
        update(touch: touch, touchInside: isTouchInside)
        
        if isTouchInside {
            let touchLocation = touch.location(in: self)
            centerPreview(at: touchLocation)
        } else {
            previewView?.transition(to: .activeFixed)
        }
        
        sendActions(for: .valueChanged)
        return true
    }
    
    /// Ends tracking a touch when the user finishes dragging.
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        guard let endTouch = touch else { return }
        update(touch: endTouch, touchInside: isTouchInside)
        
        previewView?.transition(to: .inactive)
        
        sendActions(for: isTouchInside ? .touchUpInside : .touchUpOutside)
    }
    
    /// Cancels tracking a touch when the user cancels dragging.
    public override func cancelTracking(with event: UIEvent?) {
        sendActions(for: .touchCancel)
    }
}

/// :nodoc:
/// MARK: - Internal Calculations
fileprivate extension ColorSlider {
    /// Updates the internal color and preview view when a touch event occurs.
    /// - parameter touch: The touch that triggered the update.
    /// - parameter touchInside: Whether the touch that triggered the update was inside the control when the event occurred.
    func update(touch: UITouch, touchInside: Bool) {
        internalColor = gradientView.color(from: internalColor, after: touch, insideSlider: touchInside)
        previewView?.colorChanged(to: color)
    }
}

/// :nodoc:
/// MARK: - Increase Tappable Area
extension ColorSlider {
    /// Increase the tappable area of `ColorSlider` to a minimum of 44 points on either edge.
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // If hidden, don't customize behavior
        guard !isHidden else { return super.hitTest(point, with: event) }
        
        // Determine the delta between the width / height and 44, the iOS HIG minimum tap target size.
        // If a side is already longer than 44, add 10 points of padding to either side of the slider along that axis.
        let minimumSideLength: CGFloat = 44
        let padding: CGFloat = -20
        let dx: CGFloat = min(bounds.width - minimumSideLength, padding)
        let dy: CGFloat = min(bounds.height - minimumSideLength, padding)
        
        // If an increased tappable area is needed, respond appropriately
        let increasedTapAreaNeeded = (dx < 0 || dy < 0)
        let expandedBounds = bounds.insetBy(dx: dx / 2, dy: dy / 2)
        
        if increasedTapAreaNeeded && expandedBounds.contains(point) {
            for subview in subviews.reversed() {
                let convertedPoint = subview.convert(point, from: self)
                if let hitTestView = subview.hitTest(convertedPoint, with: event) {
                    return hitTestView
                }
            }
            return self
        } else {
            return super.hitTest(point, with: event)
        }
    }
}


public class DefaultPreviewView: UIView {
    /// The animation duration when showing the preview. Defaults to `0.15`.
    public var animationDuration: TimeInterval = 0.15
    
    /// The side of the `ColorSlider` on which to show the preview view.
    public enum Side {
        /// Show the preview to the left of the slider. Valid when the ColorSlider orientation is vertical.
        case left
        
        /// Show the preview to the right of the slider. Valid when the ColorSlider orientation is vertical.
        case right
        
        /// Show the preview to the top of the slider. Valid when the ColorSlider orientation is horizontal.
        case top
        
        /// Show the preview to the bottom of the slider. Valid when the ColorSlider orientation is horizontal.
        case bottom
    }
    
    /// The side of the ColorSlider that the preview should show on. Defaults to `.left`.
    public var side: Side {
        didSet {
            calculateOffset()
        }
    }
    
    /// The scale of the slider for each preview state.
    /// Defaults to:
    /// * `.inactive`: `1`
    /// * `.activeFixed`: `1.2`
    /// * `.active`: `1.6`
    public var scaleAmounts: [PreviewState: CGFloat] = [.inactive: 1.0,
                                                        .activeFixed: 1.1,
                                                        .active: 1.3]
    
    /// The number of points to offset the preview view from the slider when the state is set to `.active`. Defaults to `50`.
    public var offsetAmount: CGFloat = 20 {
        didSet {
            calculateOffset()
        }
    }
    
    /// The actual offset of the preview view, calculated from `offsetAmount` and `side`.
    /// This value is calculated automatically in `calculateOffset` and should only be modified externally by subclasses.
    public var offset: CGPoint
    
    /// The view that displays the current color as its `backgroundColor`.
    public let colorView: UIView = UIView()
    
    /// Enable haptics on iPhone 7 and above for state transitions to/from `.activeFixed`. Defaults to `true`.
    public var hapticsEnabled: Bool = true
    
    /// :nodoc:
    /// The last state that occurred, used to trigger haptic feedback when a selection occurs.
    fileprivate var lastState: PreviewState = .inactive
    
    /// Initialize with a specific side.
    /// - parameter side: The side of the `ColorSlider` to show on. Defaults to `.left`.
    required public init(side: Side = .left) {
        self.side = side
        colorView.backgroundColor = .red
        offset = CGPoint(x: -offsetAmount, y: 0)
        
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        // Outer shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 2, height: 2)
        
        // Borders
        colorView.clipsToBounds = true
        colorView.layer.borderWidth = 1.0
        colorView.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        addSubview(colorView)
        
        calculateOffset()
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // Automatically set the preview view corner radius based on the shortest side
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        
        // Inset the color view by 3 points, round the corners
        let colorViewFrame = bounds.insetBy(dx: 3, dy: 3)
        colorView.frame = colorViewFrame
        colorView.layer.cornerRadius = min(colorViewFrame.width, colorViewFrame.height) / 2
    }
    
    /// Calculate the offset of the preview view when `offset` or `side` are set.
    public func calculateOffset() {
        switch side {
        case .left:
            offset = CGPoint(x: -offsetAmount, y: 0)
        case .right:
            offset = CGPoint(x: offsetAmount, y: 0)
        case .top:
            offset = CGPoint(x: 0, y: -offsetAmount)
        case .bottom:
            offset = CGPoint(x: 0, y: offsetAmount)
        }
    }
}

extension DefaultPreviewView: ColorSliderPreviewing {
    /// Set the `backgroundColor` of `colorView` to the new `color`.
    /// - parameter color: The new color.
    public func colorChanged(to color: UIColor) {
        colorView.backgroundColor = color
    }
    
    /// Animating to the `CGAffineTransform` with:
    /// * Translation: `offset`
    /// * Scale: `scaleAmounts[state]`
    /// - seealso: `offsetAmount`
    /// - seealso: `scaleAmounts`
    /// - seealso: `offset`
    /// - parameter state: The new state to transition to.
    public func transition(to state: PreviewState) {
        // The `.beginFromCurrentState` option allows there to be no delay when another touch occurs and a previous transition hasn't finished.
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
            // Only show the outer shadow when the state is inactive.
            self.colorView.layer.borderWidth = (state == .inactive ? 0 : 1)
            
            switch state {

            // Set the transform based on `scaleAmounts`.
            case .inactive,
                 .activeFixed:
                let scaleAmount = self.scaleAmounts[state] ?? 1
                let scaleTransform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
                self.transform = scaleTransform
                
            // Set the transform based on `scaleAmounts` and `offset`.
            case .active:
                let scaleAmount = self.scaleAmounts[state] ?? 1
                let scaleTransform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
                let translationTransform = CGAffineTransform(translationX: self.offset.x, y: self.offset.y)
                self.transform = scaleTransform.concatenating(translationTransform)
                
            }
        }, completion: nil)
        
        // Haptics
        if hapticsEnabled, #available(iOS 10.0, *) {
            switch (lastState, state) {
                
            // Medium impact haptic when first drag outside bounds occurs.
            case (.active, .activeFixed):
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
            // Light impact haptic when color selection outside bounds occurs.
            case (.activeFixed, .inactive):
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            
            // No haptic feedback for other state transitions.
            default:
                break
                
            }
        }
        
        lastState = state
    }
}


public final class GradientView: UIView {
    /// Whether the gradient should adjust its corner radius based on its bounds.
    /// When `true`, the layer's corner radius is set to `min(bounds.width, bounds.height) / 2.0` in `layoutSubviews`.
    public var automaticallyAdjustsCornerRadius: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// The saturation of all colors in the view.
    /// Defaults to `1`.
    public var saturation: CGFloat = 1 {
        didSet {
            gradient = Gradient.colorSliderGradient(saturation: saturation, whiteInset: whiteInset, blackInset: blackInset)
        }
    }
    
    /// The percent of space at the beginning (top for orientation `.vertical` and left for orientation `.horizontal`) end of the slider reserved for the color white.
    /// Defaults to `0.15`.
    public var whiteInset: CGFloat = 0.15 {
        didSet {
            gradient = Gradient.colorSliderGradient(saturation: saturation, whiteInset: whiteInset, blackInset: blackInset)
        }
    }
    
    /// The percent of space at the end (bottom for orientation `.vertical` and right for orientation `.horizontal`) end of the slider reserved for the color black.
    /// Defaults to `0.15`.
    public var blackInset: CGFloat = 0.15 {
        didSet {
            gradient = Gradient.colorSliderGradient(saturation: saturation, whiteInset: whiteInset, blackInset: blackInset)
        }
    }

    /// :nodoc:
    /// The internal gradient used to draw the view.
    fileprivate var gradient: Gradient {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// :nodoc:
    /// The orientation of the gradient view. This is always equal to the value of `orientation` in the corresponding `ColorSlider` instance.
    fileprivate let orientation: Orientation
    
    /// - parameter orientation: The orientation of the gradient view.
    required public init(orientation: Orientation) {
        self.orientation = orientation
        self.gradient = Gradient.colorSliderGradient(saturation: 1, whiteInset: 0.15, blackInset: 0.15)
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        // By default, show a border
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
        
        // Set up based on orientation
        switch orientation {
        case .vertical:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        case .horizontal:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        }
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// :nodoc:
// MARK: - Layer and Internal Drawing
public extension GradientView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    fileprivate var gradientLayer: CAGradientLayer {
        guard let gradientLayer = self.layer as? CAGradientLayer else {
            fatalError("Layer must be a gradient layer.")
        }
        return gradientLayer
    }
    
    override func draw(_ rect: CGRect) {
        gradientLayer.colors = gradient.colors.map({ (hsbColor) -> CGColor in
            return UIColor(hsbColor: hsbColor).cgColor
        })
        gradientLayer.locations = gradient.locations as [NSNumber]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Automatically adjust corner radius if needed
        if automaticallyAdjustsCornerRadius {
            let shortestSide = min(bounds.width, bounds.height)
            let automaticCornerRadius = shortestSide / 2.0
            if layer.cornerRadius != automaticCornerRadius {
                layer.cornerRadius = automaticCornerRadius
            }
        }
    }
}

// MARK: - Math
/// :nodoc:
internal extension GradientView {
    /// Determines the new color value after a touch event occurs. The behavior is defined as follows:
    /// **When `insideSlider == true`, if the touch is:**
    ///     * In the first `whiteInset` percent of the slider, return white.
    ///     * In the last `blackInset` percent of the slider, return black.
    ///     * In between, return the `HSBColor` with the following values:
    ///         * Hue: Determined based on the touch position within the slider, given the orientation.
    ///         * Saturation: `self.saturation`
    ///            * Brightness: `1`
    /// **When `insideSlider == false`**:
    ///     * Hue: Keep constant.
    ///        * Saturation: Adjust based on touch location along axis parallel to `orientation`.
    ///        * Brightness: Adjust based on touch location along axis perpendicular to `orientation`.
    ///
    /// - parameter oldColor: The last color before the touch occurred.
    /// - parameter touch: The touch that triggered the color change.
    /// - parameter insideSlider: Whether the touch that triggered the color change was inside the slider.
    /// - returns: The resulting color.
    func color(from oldColor: HSBColor, after touch: UITouch, insideSlider: Bool) -> HSBColor {
        var color = oldColor

        if insideSlider {
            // Hue: adjust based on touch location in ColorSlider bounds.
            // Saturation: Keep constant.
            // Brightness: Set equal to 100%.
            
            // Determine the progress of a touch along the slider given self.orientation
            let progress = touch.progress(in: self, withOrientation: orientation)
            
            // Set hue based on percent
            color = calculateColor(for: progress)
        } else {
            // Hue: Keep constant.
            // Saturation: Adjust based on touch location along axis parallel to self.orientation.
            // Brightness: Adjust based on touch location along axis perpendicular to self.orientation.
            
            guard let containingView = touch.view?.superview else { return color }
            let horizontalPercent = touch.progress(in: containingView, withOrientation: .horizontal)
            let verticalPercent = touch.progress(in: containingView, withOrientation: .vertical)
            
            switch orientation {
            case .vertical:
                color.saturation = horizontalPercent
                color.brightness = 1 - verticalPercent
            case .horizontal:
                color.saturation = 1 - verticalPercent
                color.brightness = horizontalPercent
            }
            
            // If `oldColor` is grayscale, black or white was selected before the touch exited the bounds of the slider.
            // Maintain the grayscale color as the touch continues outside the bounds so gray colors can be selected.
            if oldColor.isGrayscale {
                color.saturation = 0
            }
        }
        
        return color
    }
    
    /// Determines the corresponding HSBColor for a point the slider.
    /// The `sliderProgress` (ranging from 0.0 to 1.0) is used in `color(from:after:insideSlider:)` for touches inside the slider.
    /// - parameter sliderProgress: The "progress" of a touch relative to the width or height of the gradient view, given the `orientation`.
    ///                The hue is equal to `point.x / bounds.width` when `orientation == .horizontal` and `point.y / bounds.height` when `orientation == .vertical`.
    /// - returns: The corresponding HSBColor.
    func calculateColor(for sliderProgress: CGFloat) -> HSBColor {
        return gradient.color(at: sliderProgress)
    }
    
    /// Determines the corresponding point on the slider for a HSBColor.
    /// The `sliderProgress` (ranging from 0.0 to 1.0) is used in `color(from:after:insideSlider:)` for touches inside the slider.
    /// - parameter color: A HSBColor value for which a closest-match "progress" value along the slider is to be determined.
    /// - returns: The closest-match "progress" value along the slider for `color`.
    func calculateSliderProgress(for color: HSBColor) -> CGFloat {
        var sliderProgress: CGFloat = 0.0
        if color.isGrayscale {
            // If the color is grayscale, find the closest matching percent along the slider
            if color.brightness > 0.5 {
                sliderProgress = whiteInset / 2
            } else {
                sliderProgress = 1 - (blackInset / 2)
            }
        } else {
            // Otherwise, calculate the percent corresponding to the color's hue in the non-grayscale part of the slider
            let spaceForNonGrayscaleColors = 1 - blackInset - whiteInset
            sliderProgress = ((1 - color.hue) * spaceForNonGrayscaleColors) + whiteInset
        }
        return sliderProgress
    }
}

fileprivate extension Gradient {
    static func colorSliderGradient(saturation: CGFloat, whiteInset: CGFloat, blackInset: CGFloat) -> Gradient {
        // Values from 0 to 1 at intervals of 0.1
        let values: [CGFloat] = [0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.99]
        
        // Use these values as the hues for non-white and non-black colors
        let hues = values
        let nonGrayscaleColors = hues.map({ (hue) -> HSBColor in
            return HSBColor(hue: hue, saturation: saturation, brightness: 1)
        }).reversed()
        
        // Black and white are at the top and bottom of the slider, insert colors in between
        let spaceForNonGrayscaleColors = 1 - whiteInset - blackInset
        let nonGrayscaleLocations = values.map { (location) -> CGFloat in
            return whiteInset + (location * spaceForNonGrayscaleColors)
        }
        
        // Add black and white to locations and colors, set up gradient layer
        let colors = [HSBColor.white] + nonGrayscaleColors + [HSBColor.black]
        let locations = [0] + nonGrayscaleLocations + [1]
        return Gradient(colors: colors, locations: locations)
    }
}


public typealias PreviewView = UIView & ColorSliderPreviewing

/// The display state of a preview view.
public enum PreviewState {
    /// The color is not being changed and the preview view is centered at the last modified point.
    case inactive
    
    /// The color is still being changed, but the preview view center is fixed.
    /// This occurs when a touch begins inside the slider but continues outside of it.
    /// In this case, the color is actively being modified, but the preview remains fixed at
    /// the same position that it was when the touch moved outside of the slider.
    case activeFixed
    
    /// The color is being actively changed and the preview view center will be updated to match the current color.
    case active
}

/// A protocol defining callback methods for a `ColorSlider` preview view.
///
/// To create a custom preview view, create a `UIView` subclass and implement `ColorSliderPreviewing`.
/// Then, create an instance of your custom preview view and pass it to the `ColorSlider` initializer.
/// As a user drags their finger, `ColorSlider` will automatically set your preview view's `center`
/// to the point closest to the touch, centered along the axis perpendicular to the `ColorSlider`'s orientation.
///
/// If `autoresizesSubviews` is `true` (the default value on all `UIView`s) on your `ColorSlider`, your preview view
/// will also be automatically resized when its `center` point is being set. To disable resizing your preview, set
/// the `autoresizesSubviews` property on your `ColorSlider` to `false`.
public protocol ColorSliderPreviewing {
    /// Called when the color of the slider changes, so the preview can respond correctly.
    /// - parameter color: The newly selected color.
    func colorChanged(to color: UIColor)
    
    /// Called when the preview changes state and should update its appearance appropriately.
    /// Since `ColorSlider` sets the `center` of your preview automatically, you should use your
    /// view's `transform` to adjust or animate most changes. See `DefaultPreviewView` for an example.
    /// - parameter state: The new state of the preview view.
    func transition(to state: PreviewState)
}


/// :nodoc:
/// An [HSB](https://en.wikipedia.org/wiki/HSL_and_HSV) color value type.
internal struct HSBColor: Equatable {
    static let black = HSBColor(hue: 0, saturation: 1, brightness: 0)
    static let white = HSBColor(hue: 1, saturation: 0, brightness: 1)
    
    var hue: CGFloat = 0
    var saturation: CGFloat = 1
    var brightness: CGFloat = 1
    
    var isGrayscale: Bool {
        return saturation == 0
    }
    
    init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
    }
    
    init(color: UIColor) {
        color.getHue(&self.hue, saturation: &self.saturation, brightness: &self.brightness, alpha: nil)
    }
    
    static func between(color: HSBColor, and otherColor: HSBColor, percent: CGFloat) -> HSBColor {
        let hue = min(color.hue, otherColor.hue) + (abs(color.hue - otherColor.hue) * percent)
        let saturation = min(color.saturation, otherColor.saturation) + (abs(color.saturation - otherColor.saturation) * percent)
        let brightness = min(color.brightness, otherColor.brightness) + (abs(color.brightness - otherColor.brightness) * percent)
        return HSBColor(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    static func ==(lhs: HSBColor, rhs: HSBColor) -> Bool {
        return lhs.hue == rhs.hue &&
               lhs.saturation == rhs.saturation &&
               lhs.brightness == rhs.brightness
    }
}

/// :nodoc:
internal extension UIColor {
    /// A convenience initializer to create a `UIColor` from an `HSBColor`.
    convenience init(hsbColor: HSBColor) {
        self.init(hue: hsbColor.hue, saturation: hsbColor.saturation, brightness: hsbColor.brightness, alpha: 1)
    }
}


/// :nodoc:
/// A gradient value type.
internal struct Gradient {
    public let colors: [HSBColor]
    public let locations: [CGFloat]
    
    init(colors: [HSBColor], locations: [CGFloat]) {
        assert(locations.count >= 2, "There must be at least two locations to create a gradient.")
        assert(colors.count == locations.count, "The number of colors and number of locations must be equal.")
        
        locations.forEach { (location) in
            assert(location >= 0.0 && location <= 1.0, "Location must be between 0 and 1.")
        }
        
        // Create a sequence of the pairings, sorted ascending by location
        let pairs = zip(colors, locations).sorted { $0.1 < $1.1 }
        
        // Assign the internal colors and locations from the pairs
        self.colors = pairs.map { $0.0 }
        self.locations = pairs.map { $0.1 }
    }
    
    func color(at percent: CGFloat) -> HSBColor {
        assert(percent >= 0.0 && percent <= 1.0, "Percent must be between 0 and 1.")

        // Find the indices that contain the closest values below and above `percent`
        guard let maxIndex = locations.firstIndex (where: { (location) -> Bool in
            return location >= percent
        }) else { return colors[locations.endIndex] }
        guard maxIndex > locations.startIndex else { return colors[maxIndex] }
        let minIndex = locations.index(before: maxIndex)
        
        // Get the two locations
        let minLocation = locations[minIndex]
        let maxLocation = locations[maxIndex]
        
        // Get the two colors
        let leftColor = colors[minIndex]
        let rightColor = colors[maxIndex]
        
        // Calculate the percentage between the two colors that we want to find
        var scaledPercentage = (percent - minLocation) / (maxLocation - minLocation)
        if leftColor.hue > rightColor.hue && !leftColor.isGrayscale {
            scaledPercentage = 1 - scaledPercentage
        }
        
        return HSBColor.between(color: leftColor, and: rightColor, percent: scaledPercentage)
    }
}


/// :nodoc:
internal extension Range {
    /// Constrain a `Bound` value by `self`.
    /// Equivalent to max(lowerBound, min(upperBound, value)).
    /// - parameter value: The value to be clamped.
    func clamp(_ value: Bound) -> Bound {
        return lowerBound > value ? lowerBound
             : upperBound < value ? upperBound
             : value
    }
}

/// :nodoc:
internal extension UITouch {
    /// Calculate the "progress" of a touch in a view with respect to an orientation.
    /// - parameter view: The view to be used as a frame of reference.
    /// - parameter orientation: The orientation with which to determine the return value.
    /// - returns: The percent across the `view` that the receiver's location is, relative to the `orientation`. Constrained to (0, 1).
    func progress(in view: UIView, withOrientation orientation: Orientation) -> CGFloat {
        let touchLocation = self.location(in: view)
        var progress: CGFloat = 0
        
        switch orientation {
        case .vertical:
            progress = touchLocation.y / view.bounds.height
        case .horizontal:
            progress = touchLocation.x / view.bounds.width
        }
        
        return (0.0..<1.0).clamp(progress)
    }
}
