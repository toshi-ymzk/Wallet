//
//  WalletDetailViewModel.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/14.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import Combine

class  WalletDetailViewModel {
    
    let cardRatio: CGFloat = 1 / 1.618
    lazy var cardWidth = UIScreen.main.bounds.width - 30 * 2
    lazy var cardHeight = floor(cardWidth * cardRatio)
    
    @Published var paymentMethod: PaymentMethodProtocol
    
    init(paymentMethod: PaymentMethodProtocol) {
        self.paymentMethod = paymentMethod
    }
}
