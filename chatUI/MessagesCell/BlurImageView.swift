//
//  BlurImageView.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/22/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

class BlurImageView: UIView {

    private var backgroundImageView: UIImageView!
    private var foregroundImageView: UIImageView!

    private lazy var blurEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIVisualEffect())

    @IBInspectable
    public var alphaForBlurEffect: CGFloat = 0.7 {
        didSet {
            applyBlur()
        }
    }

    public var blurEffect = UIBlurEffect(style: .regular) {
        didSet {
            applyBlur()
        }
    }

    @IBInspectable
    public var image: UIImage? {
        set {
            backgroundImageView.image = newValue
            foregroundImageView.image = newValue
        }
        get {
            return foregroundImageView.image
        }
    }

    // MARK: Initilisation
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImages()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImages()
    }

    private func createBlurEffectView() -> UIVisualEffectView {

        // create effect
        let effectView = UIVisualEffectView(effect: blurEffect)

        // set boundry and alpha
        effectView.frame = self.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.alpha = alphaForBlurEffect

        return effectView
    }

    fileprivate func addImageView() -> UIImageView {
        let imageView = UIImageView(frame: self.bounds)
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        return imageView
    }

    private func setupImages() {

        self.clipsToBounds = true

     
        // Setup background view
        backgroundImageView = addImageView()
        backgroundImageView.contentMode = .scaleAspectFill
        applyBlur()

        // setup foreground view
        foregroundImageView = addImageView()
        foregroundImageView.contentMode = .scaleAspectFill

    }

    private func applyBlur() {
        blurEffectView.removeFromSuperview()

        // generate new view
        blurEffectView = createBlurEffectView()

        backgroundImageView.addSubview(blurEffectView)
    }

}
