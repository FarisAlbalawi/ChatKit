//
//  CropPickerView.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/27/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

// CropPickerView Delegate
public protocol CropPickerViewDelegate: class {
    // Called when the image is successfully extracted.
    func cropPickerView(_ cropPickerView: CropPickerView, image: UIImage)
    // Called when an attempt to extract an image fails.
    func cropPickerView(_ cropPickerView: CropPickerView, error: Error)
}

@IBDesignable
public class CropPickerView: UIView {
    public weak var delegate: CropPickerViewDelegate?
    
    // MARK: Public Property
    
    // Set Image
    @IBInspectable
    public var image: UIImage? {
        get {
            return self.imageView.image
        }
        set {
            self.imageView.image = newValue
            self.scrollView.setZoomScale(1, animated: false)
            if self.scrollView.delegate == nil {
                self.initVars()
            }
            self.cropLineHidden(newValue)
            self.scrollView.layoutIfNeeded()
            self.dimLayerMask(animated: false)
            DispatchQueue.main.async {
                self.imageMinAdjustment(animated: false)
            }
        }
    }
    
    // Set Image
    @IBInspectable
    public var changeImage: UIImage? {
        get {
            return self.imageView.image
        }
        set {
            self.imageView.image = newValue
        }
    }
    
    // Line color of crop view
    @IBInspectable
    public var cropLineColor: UIColor? {
        get {
            return self.cropView.lineColor
        }
        set {
            self.cropView.lineColor = newValue
            self.leftTopButton.edgeLine(newValue)
            self.leftBottomButton.edgeLine(newValue)
            self.rightTopButton.edgeLine(newValue)
            self.rightBottomButton.edgeLine(newValue)
            self.topButton.edgeLine(newValue)
            self.leftButton.edgeLine(newValue)
            self.rightButton.edgeLine(newValue)
            self.bottomButton.edgeLine(newValue)
        }
    }
    
    // Background color of scroll
    @IBInspectable
    public var scrollBackgroundColor: UIColor? {
        get {
            return self.scrollView.backgroundColor
        }
        set {
            self.scrollView.backgroundColor = newValue
        }
    }
    
    // Background color of image
    @IBInspectable
    public var imageBackgroundColor: UIColor? {
        get {
            return self.imageView.backgroundColor
        }
        set {
            self.imageView.backgroundColor = newValue
        }
    }
    
    // Color of dim view not in the crop area
    @IBInspectable
    public var dimBackgroundColor: UIColor? {
        get {
            return self.dimView.backgroundColor
        }
        set {
            self.dimView.backgroundColor = newValue
        }
    }
    
    // Minimum zoom for scrolling
    @IBInspectable
    public var scrollMinimumZoomScale: CGFloat {
        get {
            return self.scrollView.minimumZoomScale
        }
        set {
            self.scrollView.minimumZoomScale = newValue
        }
    }
    
    // Maximum zoom for scrolling
    @IBInspectable
    public var scrollMaximumZoomScale: CGFloat {
        get {
            return self.scrollView.maximumZoomScale
        }
        set {
            self.scrollView.maximumZoomScale = newValue
        }
    }
    
    // If false, the cropview and dimview will disappear and only the view will be zoomed in or out.
    public var isCrop = true {
        willSet {
            self.topButton.isHidden = !newValue
            self.bottomButton.isHidden = !newValue
            self.leftButton.isHidden = !newValue
            self.rightButton.isHidden = !newValue
            self.leftTopButton.isHidden = !newValue
            self.leftBottomButton.isHidden = !newValue
            self.rightTopButton.isHidden = !newValue
            self.rightBottomButton.isHidden = !newValue
            self.centerButton.isHidden = !newValue
            self.dimView.isHidden = !newValue
            self.cropView.isHidden = !newValue
        }
    }
    
    // MARK: Private Property
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        self.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.edgesConstraint(subView: scrollView)
        return scrollView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        self.scrollView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.edgesConstraint(subView: imageView)
        self.scrollView.sizeConstraint(subView: imageView)
        return imageView
    }()
    
    private lazy var dimView: CropDimView = {
        self.scrollView.alpha = 1
        let view = CropDimView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.edgesConstraint(subView: view)
        return view
    }()
    
    private lazy var cropView: CropView = {
        self.dimView.alpha = 1
        let cropView = CropView()
        self.addSubview(cropView)
        cropView.translatesAutoresizingMaskIntoConstraints = false
        self.cropLeadingConstraint = self.leadingConstraint(subView: cropView, constant: 0).priority(945)
        self.cropTrailingConstraint = self.trailingConstraint(subView: cropView, constant: 0).priority(945)
        self.cropTopConstraint = self.topConstraint(subView: cropView, constant: 0).priority(945)
        self.cropBottomConstraint = self.bottomConstraint(subView: cropView, constant: 0).priority(945)
        return cropView
    }()
    
    // Side button and corner button of crop
    
    private lazy var leftTopButton: LineButton = {
        let button = LineButton(.leftTop)
        let cropView = self.cropView
        self.addSubview(button)
        self.topConstraint(item: cropView, subView: button, constant: 10)
        self.leadingConstraint(item: cropView, subView: button, constant: 10)
        button.addTarget(self, action: #selector(self.cropButtonLeftTopDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    private lazy var leftBottomButton: LineButton = {
        let button = LineButton(.leftBottom)
        let cropView = self.cropView
        self.addSubview(button)
        self.bottomConstraint(item: cropView, subView: button, constant: -10)
        self.leadingConstraint(item: cropView, subView: button, constant: 10)
        button.addTarget(self, action: #selector(self.cropButtonLeftBottomDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    private lazy var rightTopButton: LineButton = {
        let button = LineButton(.rightTop)
        let cropView = self.cropView
        self.addSubview(button)
        self.topConstraint(item: cropView, subView: button, constant: 10)
        self.trailingConstraint(item: cropView, subView: button, constant: -10)
        button.addTarget(self, action: #selector(self.cropButtonRightTopDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    private lazy var rightBottomButton: LineButton = {
        let button = LineButton(.rightBottom)
        let cropView = self.cropView
        self.addSubview(button)
        self.bottomConstraint(item: cropView, subView: button, constant: -10)
        self.trailingConstraint(item: cropView, subView: button, constant: -10)
        button.addTarget(self, action: #selector(self.cropButtonRightBottomDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    private lazy var topButton: LineButton = {
        let button = LineButton(.top)
        let cropView = self.cropView
        self.addSubview(button)
        self.topConstraint(item: cropView, subView: button, constant: 10)
        self.centerXConstraint(item: cropView, subView: button)
        button.addTarget(self, action: #selector(self.cropButtonTopDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    private lazy var leftButton: LineButton = {
        let button = LineButton(.left)
        let cropView = self.cropView
        self.addSubview(button)
        self.centerYConstraint(item: cropView, subView: button)
        self.leadingConstraint(item: cropView, subView: button, constant: 10)
        button.addTarget(self, action: #selector(self.cropButtonLeftDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    private lazy var rightButton: LineButton = {
        let button = LineButton(.right)
        let cropView = self.cropView
        self.addSubview(button)
        self.centerYConstraint(item: cropView, subView: button)
        self.trailingConstraint(item: cropView, subView: button, constant: -10)
        button.addTarget(self, action: #selector(self.cropButtonRightDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    private lazy var bottomButton: LineButton = {
        let button = LineButton(.bottom)
        let cropView = self.cropView
        self.addSubview(button)
        self.bottomConstraint(item: cropView, subView: button, constant: -10)
        self.centerXConstraint(item: cropView, subView: button)
        button.addTarget(self, action: #selector(self.cropButtonBottomDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    private lazy var centerButton: LineButton = {
        let button = LineButton(.center)
        self.addSubview(button)
        button.widthConstraint(constant: 80, relatedBy: .equal).priority = UILayoutPriority(700)
        button.heightConstraint(constant: 80, relatedBy: .equal).priority = UILayoutPriority(700)
        self.centerXConstraint(item: self.cropView, subView: button)
        self.centerYConstraint(item: self.cropView, subView: button)
        
        let leading = NSLayoutConstraint(item: self.leftButton, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: button, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: self.rightButton, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: button, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: self.topButton, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: button, attribute: .top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self.bottomButton, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: button, attribute: .bottom, multiplier: 1, constant: 0)
        
        leading.priority = UILayoutPriority(600)
        trailing.priority = UILayoutPriority(600)
        top.priority = UILayoutPriority(600)
        bottom.priority = UILayoutPriority(600)
        
        self.addConstraints([leading, trailing, top, bottom])
        button.addTarget(self, action: #selector(self.centerDoubleTap(_:)), for: .touchDownRepeat)
        button.addTarget(self, action: #selector(self.cropButtonCenterDrag(_:forEvent:)), for: .touchDragInside)
        return button
    }()
    
    private var cropLeadingConstraint: NSLayoutConstraint?
    
    private var cropTrailingConstraint: NSLayoutConstraint?
    
    private var cropTopConstraint: NSLayoutConstraint?
    
    private var cropBottomConstraint: NSLayoutConstraint?
    
    private var lineButtonTouchPoint: CGPoint?
    
    // MARK: Init
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        if self.scrollView.delegate == nil {
            self.initVars()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        if self.scrollView.delegate == nil {
            self.initVars()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: Public Method
    
    /**
     crop method.
     If there is no image to crop, Error 404 is displayed.
     If there is no image in the crop area, Error 503 is displayed.
     If the image is successfully cropped, the success delegate or callback function is called.
     **/
    public func crop(_ handler: ((Error?, UIImage?) -> Void)? = nil) {
        guard let image = self.imageView.image else {
            let error = NSError(domain: "Image is empty.", code: 404, userInfo: nil)
            handler?(error, nil)
            self.delegate?.cropPickerView(self, error: error)
            return
        }
        
        DispatchQueue.main.async {
            let imageSize = self.imageView.frameForImageInImageViewAspectFit
            let widthRate =  self.bounds.width / imageSize.width
            let heightRate = self.bounds.height / imageSize.height
            var factor: CGFloat
            if widthRate < heightRate {
                factor = image.size.width / self.scrollView.frame.width
            } else {
                factor = image.size.height / self.scrollView.frame.height
            }
            let scale = 1 / self.scrollView.zoomScale
            let imageFrame = self.imageView.imageFrame
            let x = (self.scrollView.contentOffset.x + self.cropView.frame.origin.x - imageFrame.origin.x) * scale * factor
            let y = (self.scrollView.contentOffset.y + self.cropView.frame.origin.y - imageFrame.origin.y) * scale * factor
            let width = self.cropView.frame.size.width * scale * factor
            let height = self.cropView.frame.size.height * scale * factor
            let cropArea = CGRect(x: x, y: y, width: width, height: height)
            
            guard let cropCGImage = image.cgImage?.cropping(to: cropArea) else {
                let error = NSError(domain: "There is no image in the Crop area.", code: 503, userInfo: nil)
                handler?(error, nil)
                self.delegate?.cropPickerView(self, error: error)
                return
            }
            let cropImage = UIImage(cgImage: cropCGImage)
            handler?(nil, cropImage)
            self.delegate?.cropPickerView(self, image: cropImage)
        }
    }
    
}

// MARK: Private Method Init
extension CropPickerView {
    // Side button and corner button group of crops
    private var lineButtonGroup: [LineButton] {
        return [self.leftTopButton, self.leftBottomButton, self.rightTopButton, self.rightBottomButton, self.topButton, self.leftButton, self.bottomButton, self.rightButton, self.centerButton]
    }
    
    // Init
    private func initVars() {
        self.scrollView.clipsToBounds = true
        self.scrollView.delegate = self
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = .scaleAspectFit
        
        self.cropLineHidden(self.image)
        
        self.cropLineColor = self.cropLineColor ?? .white
        self.scrollMinimumZoomScale = 0.3
        self.scrollMaximumZoomScale = 5
        self.scrollBackgroundColor = self.scrollBackgroundColor ?? .black
        self.imageBackgroundColor = self.imageBackgroundColor ?? .black
        self.dimBackgroundColor = self.dimBackgroundColor ?? UIColor(white: 0, alpha: 0.6)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTapGesture)
        
        self.lineButtonGroup.forEach { (button) in
            button.delegate = self
            button.addTarget(self, action: #selector(self.cropButtonTouchDown(_:forEvent:)), for: .touchDown)
            button.addTarget(self, action: #selector(self.cropButtonTouchUpInside(_:forEvent:)), for: .touchUpInside)
        }
    }
    
    // Does not display lines when the image is nil.
    private func cropLineHidden(_ image: UIImage?) {
        self.cropView.alpha = image == nil ? 0 : 1
        self.leftTopButton.alpha = image == nil ? 0 : 1
        self.leftBottomButton.alpha = image == nil ? 0 : 1
        self.rightBottomButton.alpha = image == nil ? 0 : 1
        self.rightTopButton.alpha = image == nil ? 0 : 1
        self.topButton.alpha = image == nil ? 0 : 1
        self.bottomButton.alpha = image == nil ? 0 : 1
        self.leftButton.alpha = image == nil ? 0 : 1
        self.rightButton.alpha = image == nil ? 0 : 1
    }
}

// MARK: Private Method Touch Action
extension CropPickerView {
    // Center Button Double Tap
    @objc private func centerDoubleTap(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.imageDoubleTap(sender)
        }
    }
    
    // ImageView Double Tap
    @objc private func imageDoubleTap(_ sender: UITapGestureRecognizer) {
        if self.scrollView.zoomScale == 1 {
            self.imageRealSize(true)
            DispatchQueue.main.async {
                self.imageMaxAdjustment(animated: true)
            }
        } else {
            self.scrollView.setZoomScale(1, animated: true)
            DispatchQueue.main.async {
                self.imageMinAdjustment(animated: true)
            }
        }
    }
    
    // Touch Down Button
    @objc private func cropButtonTouchDown(_ sender: LineButton, forEvent event: UIEvent) {
        guard let touch = event.touches(for: sender)?.first else { return }
        self.lineButtonTouchPoint = touch.location(in: self.cropView)
        self.cropView.line(false, animated: true)
        self.dimLayerMask(animated: false)
        self.lineButtonGroup
            .filter { sender != $0 }
            .forEach { $0.isUserInteractionEnabled = false }
    }
    
    // Touch Up Inside Button
    @objc private func cropButtonTouchUpInside(_ sender: LineButton, forEvent event: UIEvent) {
        self.lineButtonTouchPoint = nil
        self.cropView.line(true, animated: true)
        self.dimLayerMask(animated: false)
        self.lineButtonGroup
            .forEach { $0.isUserInteractionEnabled = true }
    }
    
    private func cropButtonDrag(_ sender: LineButton, forEvent event: UIEvent) -> CGPoint? {
        guard let touch = event.touches(for: sender)?.first else { return nil }
        return touch.location(in: self.cropView)
    }
    
    @objc private func cropButtonLeftTopDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropLeadingConstraint = self.cropLeadingConstraint,
            let cropTrailingConstraint = self.cropTrailingConstraint,
            let cropTopConstraint =  self.cropTopConstraint,
            let cropBottomConstraint =  self.cropBottomConstraint else { return }
        guard let touchPoint = self.lineButtonTouchPoint,
            let currentPoint = self.cropButtonDrag(sender, forEvent: event) else { return }
        
        let hConstant = cropLeadingConstraint.constant - (currentPoint.x - touchPoint.x)
        let vConstant = cropTopConstraint.constant - (currentPoint.y - touchPoint.y)
        
        if (hConstant <= 0 || currentPoint.x - touchPoint.x > 0) && self.bounds.width + (hConstant - cropTrailingConstraint.constant) > 100 {
            self.cropLeadingConstraint?.constant = hConstant
        }
        if (vConstant <= 0 || currentPoint.y - touchPoint.y > 0) && self.bounds.height + (vConstant - cropBottomConstraint.constant) > 100 {
            self.cropTopConstraint?.constant = vConstant
        }
        self.dimLayerMask(animated: false)
    }
    
    @objc private func cropButtonLeftBottomDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropLeadingConstraint = self.cropLeadingConstraint,
            let cropTrailingConstraint = self.cropTrailingConstraint,
            let cropTopConstraint =  self.cropTopConstraint,
            let cropBottomConstraint =  self.cropBottomConstraint else { return }
        guard let touchPoint = self.lineButtonTouchPoint,
            let currentPoint = self.cropButtonDrag(sender, forEvent: event) else { return }
        
        self.lineButtonTouchPoint?.y = currentPoint.y
        
        let hConstant = cropLeadingConstraint.constant - (currentPoint.x - touchPoint.x)
        let vConstant = cropBottomConstraint.constant - (currentPoint.y - touchPoint.y)
        
        if (hConstant <= 0 || currentPoint.x - touchPoint.x > 0) && self.bounds.width + (hConstant - cropTrailingConstraint.constant) > 100 {
            self.cropLeadingConstraint?.constant = hConstant
        }
        if (vConstant > 0 || currentPoint.y - touchPoint.y < 0) && self.bounds.height - (vConstant - cropTopConstraint.constant) > 100 {
            self.cropBottomConstraint?.constant = vConstant
        }
        self.dimLayerMask(animated: false)
    }
    
    @objc private func cropButtonRightTopDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropLeadingConstraint = self.cropLeadingConstraint,
            let cropTrailingConstraint = self.cropTrailingConstraint,
            let cropTopConstraint =  self.cropTopConstraint,
            let cropBottomConstraint =  self.cropBottomConstraint else { return }
        guard let touchPoint = self.lineButtonTouchPoint,
            let currentPoint = self.cropButtonDrag(sender, forEvent: event) else { return }
        
        self.lineButtonTouchPoint?.x = currentPoint.x
        
        let hConstant = cropTrailingConstraint.constant - (currentPoint.x - touchPoint.x)
        let vConstant = cropTopConstraint.constant - (currentPoint.y - touchPoint.y)
        
        if (hConstant > 0 || currentPoint.x - touchPoint.x < 0) && self.bounds.width - (hConstant - cropLeadingConstraint.constant) > 100 {
            self.cropTrailingConstraint?.constant = hConstant
        }
        if (vConstant <= 0 || currentPoint.y - touchPoint.y > 0) && self.bounds.height + (vConstant - cropBottomConstraint.constant) > 100 {
            self.cropTopConstraint?.constant = vConstant
        }
        self.dimLayerMask(animated: false)
    }
    
    @objc private func cropButtonRightBottomDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropLeadingConstraint = self.cropLeadingConstraint,
            let cropTrailingConstraint = self.cropTrailingConstraint,
            let cropTopConstraint =  self.cropTopConstraint,
            let cropBottomConstraint =  self.cropBottomConstraint else { return }
        guard let touchPoint = self.lineButtonTouchPoint,
            let currentPoint = self.cropButtonDrag(sender, forEvent: event) else { return }
        
        self.lineButtonTouchPoint?.x = currentPoint.x
        self.lineButtonTouchPoint?.y = currentPoint.y
        
        let hConstant = cropTrailingConstraint.constant - (currentPoint.x - touchPoint.x)
        let vConstant = cropBottomConstraint.constant - (currentPoint.y - touchPoint.y)
        
        if (hConstant > 0 || currentPoint.x - touchPoint.x < 0) && self.bounds.width - (hConstant - cropLeadingConstraint.constant) > 100 {
            self.cropTrailingConstraint?.constant = hConstant
        }
        if (vConstant > 0 || currentPoint.y - touchPoint.y < 0) && self.bounds.height - (vConstant - cropTopConstraint.constant) > 100 {
            self.cropBottomConstraint?.constant = vConstant
        }
        self.dimLayerMask(animated: false)
    }
    
    @objc private func cropButtonLeftDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropLeadingConstraint = self.cropLeadingConstraint,
            let cropTrailingConstraint = self.cropTrailingConstraint else { return }
        guard let touchPoint = self.lineButtonTouchPoint,
            let currentPoint = self.cropButtonDrag(sender, forEvent: event) else { return }
        
        let hConstant = cropLeadingConstraint.constant - (currentPoint.x - touchPoint.x)
        
        if (hConstant <= 0 || currentPoint.x - touchPoint.x > 0) && self.bounds.width + (hConstant - cropTrailingConstraint.constant) > 100 {
            self.cropLeadingConstraint?.constant = hConstant
        }
        self.dimLayerMask(animated: false)
    }
    
    @objc private func cropButtonTopDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropTopConstraint =  self.cropTopConstraint,
            let cropBottomConstraint =  self.cropBottomConstraint else { return }
        guard let touchPoint = self.lineButtonTouchPoint,
            let currentPoint = self.cropButtonDrag(sender, forEvent: event) else { return }
        
        let vConstant = cropTopConstraint.constant - (currentPoint.y - touchPoint.y)
        
        if (vConstant <= 0 || currentPoint.y - touchPoint.y > 0) && self.bounds.height + (vConstant - cropBottomConstraint.constant) > 100 {
            self.cropTopConstraint?.constant = vConstant
        }
        self.dimLayerMask(animated: false)
    }
    
    @objc private func cropButtonRightDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropLeadingConstraint = self.cropLeadingConstraint,
            let cropTrailingConstraint = self.cropTrailingConstraint else { return }
        guard let touchPoint = self.lineButtonTouchPoint,
            let currentPoint = self.cropButtonDrag(sender, forEvent: event) else { return }
        
        self.lineButtonTouchPoint?.x = currentPoint.x
        
        let hConstant = cropTrailingConstraint.constant - (currentPoint.x - touchPoint.x)
        
        if (hConstant > 0 || currentPoint.x - touchPoint.x < 0) && self.bounds.width - (hConstant - cropLeadingConstraint.constant) > 100 {
            self.cropTrailingConstraint?.constant = hConstant
        }
        self.dimLayerMask(animated: false)
    }
    
    @objc private func cropButtonBottomDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropTopConstraint =  self.cropTopConstraint,
            let cropBottomConstraint =  self.cropBottomConstraint else { return }
        guard let touchPoint = self.lineButtonTouchPoint,
            let currentPoint = self.cropButtonDrag(sender, forEvent: event) else { return }
        
        self.lineButtonTouchPoint?.y = currentPoint.y
        
        let vConstant = cropBottomConstraint.constant - (currentPoint.y - touchPoint.y)
        
        if (vConstant > 0 || currentPoint.y - touchPoint.y < 0) && self.bounds.height - (vConstant - cropTopConstraint.constant) > 100 {
            self.cropBottomConstraint?.constant = vConstant
        }
        self.dimLayerMask(animated: false)
    }
    
    @objc private func cropButtonCenterDrag(_ sender: LineButton, forEvent event: UIEvent) {
        guard let cropLeadingConstraint = self.cropLeadingConstraint,
            let cropTrailingConstraint = self.cropTrailingConstraint,
            let cropTopConstraint =  self.cropTopConstraint,
            let cropBottomConstraint =  self.cropBottomConstraint else { return }
        guard let touchPoint = self.lineButtonTouchPoint,
            let currentPoint = self.cropButtonDrag(sender, forEvent: event) else { return }
        
        let lConstant = cropLeadingConstraint.constant - (currentPoint.x - touchPoint.x)
        let rConstant = cropTrailingConstraint.constant - (currentPoint.x - touchPoint.x)
        
        if (lConstant <= 0 || currentPoint.x - touchPoint.x > 0) &&
            (rConstant > 0 || currentPoint.x - touchPoint.x < 0) {
            self.cropLeadingConstraint?.constant = lConstant
            self.cropTrailingConstraint?.constant = rConstant
        }
        
        let tConstant = cropTopConstraint.constant - (currentPoint.y - touchPoint.y)
        let bConstant = cropBottomConstraint.constant - (currentPoint.y - touchPoint.y)
        if (tConstant <= 0 || currentPoint.y - touchPoint.y > 0) &&
            (bConstant > 0 || currentPoint.y - touchPoint.y < 0) {
            self.cropTopConstraint?.constant = tConstant
            self.cropBottomConstraint?.constant = bConstant
        }
        self.dimLayerMask(animated: false)
    }
}

// MARK: Private Method Image
extension CropPickerView {
    // Modify the contentOffset of the scrollView so that the scroll view fills the image.
    private func imageRealSize(_ animated: Bool = false) {
        if self.imageView.image == nil { return }
        self.scrollView.setZoomScale(1, animated: false)
        
        let imageSize = self.imageView.frameForImageInImageViewAspectFit
        let widthRate =  self.bounds.width / imageSize.width
        let heightRate = self.bounds.height / imageSize.height
        if widthRate < heightRate {
            self.scrollView.setZoomScale(heightRate, animated: animated)
        } else {
            self.scrollView.setZoomScale(widthRate, animated: animated)
        }
        let x = self.scrollView.contentSize.width/2 - self.scrollView.bounds.size.width/2
        let y = self.scrollView.contentSize.height/2 - self.scrollView.bounds.size.height/2
        self.scrollView.contentOffset = CGPoint(x: x, y: y)
    }
}

// MARK: Private Method Crop
extension CropPickerView {
    private func isImageRateHeightGreaterThan(_ imageSize: CGRect) -> Bool {
        let widthRate =  self.bounds.width / imageSize.width
        let heightRate = self.bounds.height / imageSize.height
        return widthRate < heightRate
    }
    
    // Max Image
    private func imageMaxAdjustment(_ duration: TimeInterval = 0.4, animated: Bool) {
        self.imageAdjustment(.zero, duration: duration, animated: animated)
    }
    
    // Min Image
    private func imageMinAdjustment(_ duration: TimeInterval = 0.4, animated: Bool) {
        var point: CGPoint
        let imageSize = self.imageView.frameForImageInImageViewAspectFit
        if self.isImageRateHeightGreaterThan(imageSize) {
            point = CGPoint(x: 0, y: imageSize.origin.y)
        } else {
            point = CGPoint(x: imageSize.origin.x, y: 0)
        }
        self.imageAdjustment(point, duration: duration, animated: animated)
    }
    
    private func imageAdjustment(_ point: CGPoint, duration: TimeInterval = 0.4, animated: Bool) {
        self.cropLeadingConstraint?.constant = -point.x
        self.cropTrailingConstraint?.constant = point.x
        self.cropTopConstraint?.constant = -point.y
        self.cropBottomConstraint?.constant = point.y
        if animated {
            self.dimLayerMask(duration, animated: animated)
            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.dimLayerMask(duration, animated: animated)
        }
    }
}

// MARK: Private Method Dim
extension CropPickerView {
    // Modify the dim screen mask.
    private func dimLayerMask(_ duration: TimeInterval = 0.4, animated: Bool) {
        guard let cropLeadingConstraint = self.cropLeadingConstraint,
            let cropTrailingConstraint = self.cropTrailingConstraint,
            let cropTopConstraint = self.cropTopConstraint,
            let cropBottomConstraint = self.cropBottomConstraint else { return }
        let width = self.scrollView.bounds.width - (-cropLeadingConstraint.constant + cropTrailingConstraint.constant)
        let height = self.scrollView.bounds.height - (-cropTopConstraint.constant + cropBottomConstraint.constant)
        self.dimView.layoutIfNeeded()
        
        let path = UIBezierPath(rect: CGRect(
            x: -cropLeadingConstraint.constant,
            y: -cropTopConstraint.constant,
            width: width,
            height: height
        ))
        path.append(UIBezierPath(rect: self.dimView.bounds))
        
        self.dimView.mask(path.cgPath, duration: duration, animated: animated)
    }
}

// MARK: LineButtonDelegate
extension CropPickerView: LineButtonDelegate {
    // When highlighted on the line button disappears, Enable interaction for all buttons.
    func lineButtonUnHighlighted() {
        self.lineButtonTouchPoint = nil
        self.cropView.line(true, animated: true)
        self.dimLayerMask(animated: false)
        self.lineButtonGroup
            .forEach { $0.isUserInteractionEnabled = true }
    }
}

// MARK: UIScrollViewDelegate
extension CropPickerView: UIScrollViewDelegate {
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale <= 1 {
            let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
            let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
            scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
        } else {
            let imageSize = self.imageView.frameForImageInImageViewAspectFit
            if self.isImageRateHeightGreaterThan(imageSize) {
                let imageOffset = -imageSize.origin.y
                let scrollOffset = (scrollView.bounds.height - scrollView.contentSize.height) * 0.5
                if imageOffset > scrollOffset {
                    scrollView.contentInset = UIEdgeInsets(top: imageOffset, left: 0, bottom: imageOffset, right: 0)
                } else {
                    scrollView.contentInset = UIEdgeInsets(top: scrollOffset, left: 0, bottom: scrollOffset, right: 0)
                }
            } else {
                let imageOffset = -imageSize.origin.x
                let scrollOffset = (scrollView.bounds.width - scrollView.contentSize.width) * 0.5
                if imageOffset > scrollOffset {
                    scrollView.contentInset = UIEdgeInsets(top: 0, left: imageOffset, bottom: 0, right: imageOffset)
                } else {
                    scrollView.contentInset = UIEdgeInsets(top: 0, left: scrollOffset, bottom: 0, right: scrollOffset)
                }
            }
        }
    }
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}



// CropDimView
class CropDimView: UIView {
    private var path: CGPath?
    
    init() {
        super.init(frame: .zero)
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func mask(_ path: CGPath, duration: TimeInterval, animated: Bool) {
        self.path = path
        if let mask = self.layer.mask as? CAShapeLayer {
            mask.removeAllAnimations()
            if animated {
                let animation = CABasicAnimation(keyPath: "path")
                animation.delegate = self
                animation.fromValue = mask.path
                animation.toValue = path
                animation.byValue = path
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                animation.isRemovedOnCompletion = false
                animation.fillMode = .forwards
                animation.duration = duration
                mask.add(animation, forKey: "path")
            } else {
                mask.path = path
            }
        } else {
            let maskLayer = CAShapeLayer()
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
            maskLayer.backgroundColor = UIColor.clear.cgColor
            maskLayer.path = path
            self.layer.mask = maskLayer
        }
    }
}


// Crop LineView
class CropView: UIView {
    private let margin: CGFloat = 0
    private let lineSize: CGFloat = 1
    
    var lineColor: UIColor? = .white {
        willSet {
            self.topLineView.backgroundColor = newValue
            self.bottomLineView.backgroundColor = newValue
            self.leftLineView.backgroundColor = newValue
            self.rightLineView.backgroundColor = newValue
            self.horizontalRightLineView.backgroundColor = newValue
            self.horizontalLeftLineView.backgroundColor = newValue
            self.verticalTopLineView.backgroundColor = newValue
            self.verticalBottomLineView.backgroundColor = newValue
        }
    }
    
    private lazy var topLineView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: self.margin).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: self.margin).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: self.margin).priority(950))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: self.lineSize).priority(950))
        return view
    }()
    
    private lazy var leftLineView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: self.margin).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: self.margin).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: self.margin).priority(950))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.lineSize).priority(950))
        return view
    }()
    
    private lazy var bottomLineView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: self.margin).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: self.margin).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: self.margin).priority(950))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: self.lineSize).priority(950))
        return view
    }()
    
    private lazy var rightLineView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: self.margin).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: self.margin).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: self.margin).priority(950))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.lineSize).priority(950))
        return view
    }()
    
    private lazy var horizontalLeftLineView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self.horizontalLeftView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.bottomLineView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.topLineView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).priority(950))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.lineSize).priority(950))
        return view
    }()
    
    private lazy var horizontalRightLineView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self.horizontalCenterView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.bottomLineView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.topLineView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).priority(950))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.lineSize).priority(950))
        return view
    }()
    
    private lazy var verticalTopLineView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self.verticalTopView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.leftLineView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.rightLineView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).priority(950))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: self.lineSize).priority(950))
        return view
    }()
    
    private lazy var verticalBottomLineView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self.verticalCenterView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.leftLineView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.rightLineView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).priority(950))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: self.lineSize).priority(950))
        return view
    }()
    
    private lazy var horizontalLeftView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self.leftLineView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.bottomLineView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.topLineView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).priority(950))
        return view
    }()
    
    private lazy var horizontalCenterView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self.horizontalLeftLineView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.bottomLineView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.topLineView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.horizontalLeftView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0).priority(950))
        return view
    }()
    
    private lazy var horizontalRightView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self.horizontalRightLineView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.bottomLineView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.topLineView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.rightLineView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.horizontalLeftView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0).priority(950))
        return view
    }()
    
    private lazy var verticalTopView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self.topLineView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.leftLineView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.rightLineView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).priority(950))
        return view
    }()
    
    private lazy var verticalCenterView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self.verticalTopLineView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.leftLineView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.rightLineView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.verticalTopView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0).priority(950))
        return view
    }()
    
    private lazy var verticalBottomView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self.verticalBottomLineView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.leftLineView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.rightLineView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.verticalTopView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0).priority(950))
        self.addConstraint(NSLayoutConstraint(item: self.bottomLineView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).priority(950))
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initVars()
    }
    
    init() {
        super.init(frame: .zero)
        
        self.initVars()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initVars()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initVars() {
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        self.topLineView.alpha = 1
        self.leftLineView.alpha = 1
        self.bottomLineView.alpha = 1
        self.rightLineView.alpha = 1
        self.horizontalLeftLineView.alpha = 0
        self.horizontalRightLineView.alpha = 0
        self.verticalTopLineView.alpha = 0
        self.verticalBottomLineView.alpha = 0
        
        self.horizontalLeftView.alpha = 0
        self.horizontalCenterView.alpha = 0
        self.horizontalRightView.alpha = 0
        self.verticalTopView.alpha = 0
        self.verticalCenterView.alpha = 0
        self.verticalBottomView.alpha = 0
    }
    
    func line(_ isHidden: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                if isHidden {
                    self.horizontalRightLineView.alpha = 0
                    self.horizontalLeftLineView.alpha = 0
                    self.verticalTopLineView.alpha = 0
                    self.verticalBottomLineView.alpha = 0
                } else {
                    self.horizontalRightLineView.alpha = 1
                    self.horizontalLeftLineView.alpha = 1
                    self.verticalTopLineView.alpha = 1
                    self.verticalBottomLineView.alpha = 1
                }
            }
        } else {
            if isHidden {
                self.horizontalRightLineView.alpha = 0
                self.horizontalLeftLineView.alpha = 0
                self.verticalTopLineView.alpha = 0
                self.verticalBottomLineView.alpha = 0
            } else {
                self.horizontalRightLineView.alpha = 1
                self.horizontalLeftLineView.alpha = 1
                self.verticalTopLineView.alpha = 1
                self.verticalBottomLineView.alpha = 1
            }
        }
    }
}

// MARK: CAAnimationDelegate
extension CropDimView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let path = self.path else { return }
        if let mask = self.layer.mask as? CAShapeLayer {
            mask.removeAllAnimations()
            mask.path = path
        }
    }
}



// Called when the button's highlighted is false.
protocol LineButtonDelegate: class {
    func lineButtonUnHighlighted()
}

// Side, Edge LineButton
class LineButton: UIButton {
    weak var delegate: LineButtonDelegate?
    
    private var type: ButtonLineType
    
    override var isHighlighted: Bool {
        didSet {
            if !self.isHighlighted {
                self.delegate?.lineButtonUnHighlighted()
            }
        }
    }
    
    // MARK: Init
    init(_ type: ButtonLineType) {
        self.type = type
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        self.setTitle(nil, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
        if type != .center {
            self.widthConstraint(constant: 50)
            self.heightConstraint(constant: 50)
            self.alpha = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func edgeLine(_ color: UIColor?) {
        self.setImage(self.type.view(color)?.imageWithView?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
}

enum ButtonLineType {
    case center
    case leftTop, rightTop, leftBottom, rightBottom, top, left, right, bottom
    
    var rotate: CGFloat {
        switch self {
        case .leftTop:
            return 0
        case .rightTop:
            return CGFloat.pi/2
        case .rightBottom:
            return CGFloat.pi
        case .leftBottom:
            return CGFloat.pi/2*3
        case .top:
            return 0
        case .left:
            return CGFloat.pi/2*3
        case .right:
            return CGFloat.pi/2
        case .bottom:
            return CGFloat.pi
        case .center:
            return 0
        }
    }
    
    var yMargin: CGFloat {
        switch self {
        case .rightBottom, .bottom:
            return 1
        default:
            return 0
        }
    }
    
    var xMargin: CGFloat {
        switch self {
        case .leftBottom:
            return 1
        default:
            return 0
        }
    }
    
    func view(_ color: UIColor?) -> UIView? {
        var view: UIView?
        if self == .leftTop || self == .rightTop || self == .leftBottom || self == .rightBottom {
            view = ButtonLineType.EdgeView(self, color: color)
        } else {
            view = ButtonLineType.SideView(self, color: color)
        }
        view?.isOpaque = false
        view?.tintColor = color
        return view
    }
    
    class LineView: UIView {
        var type: ButtonLineType
        var color: UIColor?
        init(_ type: ButtonLineType, color: UIColor?) {
            self.type = type
            self.color = color
            super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        func apply(_ path: UIBezierPath) {
            var pathTransform  = CGAffineTransform.identity
            pathTransform = pathTransform.translatedBy(x: 25, y: 25)
            pathTransform = pathTransform.rotated(by: self.type.rotate)
            pathTransform = pathTransform.translatedBy(x: -25 - self.type.xMargin, y: -25 - self.type.yMargin)
            path.apply(pathTransform)
            path.closed()
                .strokeFill(self.color ?? .white)
        }
    }
    
    class EdgeView: LineView {
        override func draw(_ rect: CGRect) {
            let path = UIBezierPath()
                .move(6, 6)
                .line(6, 20)
                .line(8, 20)
                .line(8, 8)
                .line(20, 8)
                .line(20, 6)
                .line(6, 6)
            self.apply(path)
        }
    }
    class SideView: LineView {
        override func draw(_ rect: CGRect) {
            let path = UIBezierPath()
                .move(15, 6)
                .line(35, 6)
                .line(35, 8)
                .line(15, 8)
                .line(15, 6)
            self.apply(path)
        }
    }
}

extension UIBezierPath {
    @discardableResult
    func move(_ x: CGFloat, _ y: CGFloat) -> UIBezierPath{
        self.move(to: CGPoint(x: x, y: y))
        return self
    }
    
    @discardableResult
    func line(_ x: CGFloat, _ y: CGFloat) -> UIBezierPath {
        self.addLine(to: CGPoint(x: x, y: y))
        return self
    }
    
    @discardableResult
    func closed() -> UIBezierPath {
        self.close()
        return self
    }
    
    @discardableResult
    func strokeFill(_ color: UIColor, lineWidth: CGFloat = 1) -> UIBezierPath {
        color.set()
        self.lineWidth = lineWidth
        self.stroke()
        self.fill()
        return self
    }
    
    @discardableResult
    func stroke(_ color: UIColor, lineWidth: CGFloat = 1) -> UIBezierPath {
        color.set()
        self.lineWidth = lineWidth
        self.stroke()
        return self
    }
}


extension UIImageView {
    var frameForImageInImageViewAspectFit: CGRect {
        if  let img = self.image {
            let imageRatio = img.size.width / img.size.height
            let viewRatio = self.frame.size.width / self.frame.size.height
            if(imageRatio < viewRatio) {
                let scale = self.frame.size.height / img.size.height
                let width = scale * img.size.width
                let topLeftX = (self.frame.size.width - width) * 0.5
                return CGRect(x: topLeftX, y: 0, width: width, height: self.frame.size.height)
            } else {
                let scale = self.frame.size.width / img.size.width
                let height = scale * img.size.height
                let topLeftY = (self.frame.size.height - height) * 0.5
                return CGRect(x: 0, y: topLeftY, width: self.frame.size.width, height: height)
            }
        }
        return CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    var imageFrame: CGRect {
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else { return CGRect.zero }
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
        } else {
            let scalFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scalFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
    }
}


extension UIView {
    
    var imageWithView: UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
            return renderer.image { rendererContext in
                self.layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
            if let cgContext = UIGraphicsGetCurrentContext() {
                self.layer.render(in: cgContext)
            }
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
    
    func edgesConstraint(subView: UIView, constant: CGFloat = 0) {
        self.leadingConstraint(subView: subView, constant: constant)
        self.trailingConstraint(subView: subView, constant: constant)
        self.topConstraint(subView: subView, constant: constant)
        self.bottomConstraint(subView: subView, constant: constant)
    }
    
    func sizeConstraint(subView: UIView, constant: CGFloat = 0) {
        self.widthConstraint(subView: subView, constant: constant)
        self.heightConstraint(subView: subView, constant: constant)
    }
    
    func sizeConstraint(constant: CGFloat = 0) {
        self.widthConstraint(constant: constant)
        self.heightConstraint(constant: constant)
    }
    
    @discardableResult
    func leadingConstraint(subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: relatedBy, toItem: subView, attribute: .leading, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func trailingConstraint(subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: relatedBy, toItem: subView, attribute: .trailing, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func topConstraint(subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: relatedBy, toItem: subView, attribute: .top, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func bottomConstraint(subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: relatedBy, toItem: subView, attribute: .bottom, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func centerXConstraint(subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: relatedBy, toItem: subView, attribute: .centerX, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func centerYConstraint(subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: relatedBy, toItem: subView, attribute: .centerY, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func leadingConstraint(item: UIView, subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item, attribute: .leading, relatedBy: relatedBy, toItem: subView, attribute: .leading, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func trailingConstraint(item: UIView, subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item, attribute: .trailing, relatedBy: relatedBy, toItem: subView, attribute: .trailing, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func topConstraint(item: UIView, subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item, attribute: .top, relatedBy: relatedBy, toItem: subView, attribute: .top, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func bottomConstraint(item: UIView, subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item, attribute: .bottom, relatedBy: relatedBy, toItem: subView, attribute: .bottom, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func centerXConstraint(item: UIView, subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item, attribute: .centerX, relatedBy: relatedBy, toItem: subView, attribute: .centerX, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func centerYConstraint(item: UIView, subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item, attribute: .centerY, relatedBy: relatedBy, toItem: subView, attribute: .centerY, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func widthConstraint(item: UIView, subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item, attribute: .width, relatedBy: relatedBy, toItem: subView, attribute: .width, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func heightConstraint(item: UIView, subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item, attribute: .height, relatedBy: relatedBy, toItem: subView, attribute: .height, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func widthConstraint(subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: relatedBy, toItem: subView, attribute: .width, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func heightConstraint(subView: UIView, constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: relatedBy, toItem: subView, attribute: .height, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func widthConstraint(constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: relatedBy, toItem: nil, attribute: .width, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    func heightConstraint(constant: CGFloat = 0, multiplier: CGFloat = 1, relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: relatedBy, toItem: nil, attribute: .height, multiplier: multiplier, constant: constant)
        self.addConstraint(constraint)
        return constraint
    }
}


extension NSLayoutConstraint {
    func priority(_ value: CGFloat) -> NSLayoutConstraint {
        self.priority = UILayoutPriority(Float(value))
        return self
    }
}
