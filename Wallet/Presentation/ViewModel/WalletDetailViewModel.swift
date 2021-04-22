//
//  WalletDetailViewModel.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/14.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import Combine

class  WalletDetailViewModel: ViewModelType {

    struct Argument {
        let paymentMethod: PaymentMethodProtocol
    }
    private let args: Argument

    let cardRatio: CGFloat = 1 / 1.618
    lazy var cardWidth = UIScreen.main.bounds.width - 30 * 2
    lazy var cardHeight = floor(cardWidth * cardRatio)

    enum Input {
        case viewDidLoad
    }

    enum Output {
        case layoutPaymentMethodView(method: PaymentMethodProtocol, size: CGSize)
    }

    @Published var output: Output?

    init(args: Argument) {
        self.args = args
    }

    func apply(input: Input) {
        switch input {
        case .viewDidLoad:
            output = .layoutPaymentMethodView(method: args.paymentMethod, size: .init(width: cardWidth, height: cardHeight))
        }
    }
}
