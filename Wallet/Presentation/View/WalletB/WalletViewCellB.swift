//
//  WalletViewCellB.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/12.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit

class WalletViewCellB: UICollectionViewCell {
    
    let paymentMethodView: PaymentMethodView = .init()
    
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
        paymentMethodView.pinEdgesToSuperviewEdges()
    }
}
