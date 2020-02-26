//
//  WalletViewModelC.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/12.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WalletViewModelC {
    
    let useCase: WalletUseCase
    
    let cardRatio: CGFloat = 1 / 1.618
    let cellSpace: CGFloat = 0
    
    let cardPosition = CGPoint(x: 80, y: 0)
    lazy var cardWidth = UIScreen.width - cardPosition.x + 20
    lazy var cardHeight = floor(cardWidth * cardRatio)
    
    var currentOffsetX = BehaviorRelay<CGFloat>(value: 0)
    let sectionCount: Int = 1
    
    var selectedIndex = 0
    
    var methods: [PaymentMethodProtocol] {
        return _paymentMethods.value
    }
    private var _paymentMethods = BehaviorRelay<[PaymentMethodProtocol]>(value: [])
    var paymentMethods: Driver<[PaymentMethodProtocol]> {
        return _paymentMethods.asDriver()
    }
    private var _paymentMethodError = PublishRelay<Error>()
    var paymentMethodError: Signal<Error> {
        return _paymentMethodError.asSignal()
    }
    
    private let disposeBag = DisposeBag()
    
    init(useCase: WalletUseCase) {
        self.useCase = useCase
    }
    
    func getPaymentMethods() {
        useCase.getPaymentMethods().subscribe(onSuccess: { [weak self] res in
            self?._paymentMethods.accept(res)
        }) { [weak self] err in
            self?._paymentMethodError.accept(err)
        }.disposed(by: disposeBag)
    }
}
