//
//  WalletViewModelA.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/05.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WalletViewModelA {
    
    let useCase: WalletUseCase
    
    let cardRatio: CGFloat = 1 / 1.618
    let cellSpace: CGFloat = 0
    let cellMargin: CGFloat = 30
    let collectionViewMargin: CGFloat = 30
    lazy var collectionViewHeight: CGFloat = floor(cellHeight + 60)
    lazy var cellWidth = UIScreen.main.bounds.width - cellMargin * 2
    lazy var cellHeight = floor(cellWidth * cardRatio)
    
    var currentOffsetX = BehaviorRelay<CGFloat>(value: 0)
    var currentPage = BehaviorRelay<Int>(value: 0)
    var pageCount: Int {
        return paymentMethods.value.count
    }
    let sectionCount: Int = 1
    
    var paymentMethods = BehaviorRelay<[PaymentMethodProtocol]>(value: [])
    var paymentMethodError = PublishRelay<Error>()
    
    private let disposeBag = DisposeBag()
    
    init(useCase: WalletUseCase) {
        self.useCase = useCase
    }
    
    func getPaymentMethods() {
        useCase.getPaymentMethods().subscribe(onSuccess: { [weak self] res in
            self?.paymentMethods.accept(res)
        }) { [weak self] err in
            self?.paymentMethodError.accept(err)
        }.disposed(by: disposeBag)
    }
}
