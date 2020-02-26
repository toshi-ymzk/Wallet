//
//  WalletCellC.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/12.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit

class WalletCellC: UICollectionViewCell {
    
    let paymentMethodView: PaymentMethodView = .init()
    
    let cardRatio: CGFloat = 1 / 1.618
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        addSubview(paymentMethodView)
    }
    
    func layout(method: PaymentMethodProtocol,
                cardSize: CGSize,
                cardPosition: CGPoint = .zero,
                fontSize: CGFloat = 18) {
        paymentMethodView.setDimensions(size: cardSize)
        paymentMethodView.layout(method: method, cardSize: cardSize, fontSize: fontSize)
        paymentMethodView.pinEdge(.leading, to: .leading, of: self, constant: cardPosition.x)
        paymentMethodView.pinEdge(.top, to: .top, of: self, constant: cardPosition.y)
        paymentMethodView.rotate(angle: -0.25 * CGFloat.pi)
    }
}
