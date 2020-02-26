//
//  PaymentMethodView.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/05.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit

class PaymentMethodView: UIView {
    
    @IBOutlet var cardView: UIView!
    @IBOutlet var brandName: UILabel!
    @IBOutlet var accountNumber: UILabel!
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var lightGradientView: UIView!
    @IBOutlet var shadowGradientView: UIView!
    
    @IBOutlet var brandNameTop: NSLayoutConstraint!
    @IBOutlet var brandNameLeft: NSLayoutConstraint!
    @IBOutlet var accountNumberBottom: NSLayoutConstraint!
    @IBOutlet var accountNumberLeft: NSLayoutConstraint!
    @IBOutlet var logoImageTop: NSLayoutConstraint!
    @IBOutlet var logoImageRight: NSLayoutConstraint!
    @IBOutlet var logoImageHeight: NSLayoutConstraint!
    @IBOutlet var logoImageWidth: NSLayoutConstraint!
    
    let lightGradientLayer = CAGradientLayer()
    let shadowGradientLayer = CAGradientLayer()
    
    lazy var previousMethodView: PaymentMethodView = {
        let view = PaymentMethodView(frame: self.bounds)
        addSubview(view)
        view.pinEdgesToSuperviewEdges()
        view.cardView.layer.opacity = 0
        return view
    }()
    
    static let cardRatio: CGFloat = 1.618
    var angle: CGFloat = 0
    lazy var perspective: CATransform3D = {
        var perspective = CATransform3DIdentity
        perspective.m34 = 1.0 / -500
        return perspective
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        if let view = Bundle.main.loadNibNamed(PaymentMethodView.className, owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.pinEdgesToSuperviewEdges()
//            layer.shadowColor = UIColor.black.cgColor
//            layer.shadowRadius = 6
//            layer.shadowOffset = CGSize(width: 3, height: 3)
//            layer.shadowOpacity = 0.3
            
//            brandName.layer.shadowColor = UIColor.black.cgColor
//            brandName.layer.shadowRadius = 1
//            brandName.layer.shadowOffset = CGSize(width: 1, height: 1)
//            brandName.layer.shadowOpacity = 0.3
//
//            accountNumber.layer.shadowColor = UIColor.black.cgColor
//            accountNumber.layer.shadowRadius = 1
//            accountNumber.layer.shadowOffset = CGSize(width: 1, height: 1)
//            accountNumber.layer.shadowOpacity = 0.3
            
            lightGradientLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
            lightGradientView.layer.addSublayer(lightGradientLayer)
            lightGradientView.alpha = 0.3
            
            shadowGradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
            shadowGradientView.layer.addSublayer(shadowGradientLayer)
            shadowGradientView.alpha = 0.15
        }
    }
    
    func layout(method: PaymentMethodProtocol,
                cardSize: CGSize,
                fontSize: CGFloat = 18) {
        
        lightGradientLayer.frame = CGRect(x: 0, y: 0, width: cardSize.width, height: cardSize.height)
        shadowGradientLayer.frame = CGRect(x: 0, y: 0, width: cardSize.width, height: cardSize.height)
        
        brandName.font = .boldSystemFont(ofSize: fontSize)
        accountNumber.font = .boldSystemFont(ofSize: fontSize)
        
        if let bank = method as? BankAccountModel {
            cardView.backgroundColor = bank.color
            brandName.text = bank.bankName
            accountNumber.text = bank.accountNumber
            logoImage.image = bank.logoImage
        } else if let card = method as? CreditCardModel {
            cardView.backgroundColor = card.color
            brandName.text = card.cardBrand
            accountNumber.text = String(card.cardNumber.prefix(7)) + "..."
            logoImage.image = card.logoImage
        }
        
        brandNameTop.constant = floor(cardSize.width / 10)
        brandNameLeft.constant = floor(cardSize.width / 10)
        accountNumberBottom.constant = floor(cardSize.width / 10)
        accountNumberLeft.constant = floor(cardSize.width / 10)
        logoImageTop.constant = floor(cardSize.width / 10)
        logoImageRight.constant = floor(cardSize.width / 10)
        logoImageWidth.constant = floor(cardSize.width / 5)
        if let size = logoImage.image?.size {
            logoImageHeight.constant = floor(logoImageWidth.constant * (size.height / size.width))
        }
    }
    
    func layoutWithAnimation(method: PaymentMethodProtocol,
                             previousMethod: PaymentMethodProtocol? = nil,
                             cardSize: CGSize,
                             fontSize: CGFloat = 16) {
        if let previous = previousMethod {
            previousMethodView.layout(method: previous,
                                 cardSize: cardSize,
                                 fontSize: fontSize)
            previousMethodView.hideWithAnimation()
        }
        layout(method: method,
               cardSize: cardSize,
               fontSize: fontSize)
        showWithAnimation()
    }
    
    func showWithAnimation() {
        self.cardView.layer.removeAllAnimations()
        
        let transform = CABasicAnimation(keyPath: "transform")
        transform.duration = 0.3
        transform.fromValue = CATransform3DMakeScale(0.0, 0.0, 1)
        transform.toValue = CATransform3DMakeScale(1, 1, 1)
        transform.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.cardView.layer.add(transform, forKey: nil)
        
        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.duration = 0.3
        opacity.fromValue = 0
        opacity.toValue = 1
        opacity.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.cardView.layer.add(opacity, forKey: nil)
    }
    
    func hideWithAnimation() {
        cardView.layer.removeAllAnimations()
        
        let transform = CABasicAnimation(keyPath: "transform")
        transform.duration = 0.3
        transform.fromValue = CATransform3DMakeScale(1, 1, 1)
        transform.toValue = CATransform3DMakeScale(0.0, 0.0, 1)
        transform.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        cardView.layer.add(transform, forKey: nil)
        
        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.duration = 0.3
        opacity.fromValue = 1
        opacity.toValue = 0
        opacity.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        cardView.layer.add(opacity, forKey: nil)
    }
    
    func rotate(angle: CGFloat) {
        self.angle = angle
        let transform = CATransform3DRotate(perspective, angle, 1, 0, 0)
        cardView.layer.transform = transform
    }
}
