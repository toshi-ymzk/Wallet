//
//  WalletViewModelB.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/06.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WalletViewModelB {
    
    let useCase: WalletUseCase
    
    let cardRatio: CGFloat = 1 / 1.618
    let cellSpace: CGFloat = 16
    let sectionInset: CGFloat = 16
    lazy var cellWidth = (UIScreen.main.bounds.width - sectionInset * 2 - cellSpace) / 2
    lazy var cellHeight = floor(cellWidth * cardRatio)
    
    lazy var selectedMethodViewWidth = UIScreen.main.bounds.width - sectionInset * 2
    lazy var selectedMethodViewHeight = floor(selectedMethodViewWidth * cardRatio)
    
    private var _selectedMethod = BehaviorRelay<PaymentMethodProtocol?>(value: nil)
    var selectedMethod: Observable<PaymentMethodProtocol?> {
        return _selectedMethod.asObservable()
    }
    var selectedIndex = 0 {
        didSet {
            _selectedMethod.accept(methods[selectedIndex])
        }
    }
    
    var itemCount: Int {
        return unselectedMethods.count
    }
    let sectionCount: Int = 1
    
    var unselectedMethods: [PaymentMethodProtocol] {
        return methods.enumerated()
            .filter({ $0.offset != selectedIndex })
            .map({ $0.element })
    }
    
    private var methods: [PaymentMethodProtocol] = []
    private var _paymentMethods = PublishRelay<[PaymentMethodProtocol]>()
    var paymentMethods: Observable<[PaymentMethodProtocol]> {
        return _paymentMethods.asObservable()
    }
    var paymentMethodError = PublishRelay<Error>()
    
    private let disposeBag = DisposeBag()
    
    init(useCase: WalletUseCase) {
        self.useCase = useCase
    }
    
    func getPaymentMethods() {
        useCase.getPaymentMethods().subscribe(onSuccess: { [weak self] res in
            self?.methods = res
            self?._paymentMethods.accept(res)
            if let method = res.first {
                self?._selectedMethod.accept(method)
            }
        }) { [weak self] err in
            self?.paymentMethodError.accept(err)
        }.disposed(by: disposeBag)
    }
    
    
    func getInsertIndex(index: IndexPath) -> IndexPath {
        let i = selectedIndex <= index.item ? selectedIndex : selectedIndex - 1
        return IndexPath(item: i, section: 0)
    }
    
    func setSelectedIndex(index: IndexPath) {
        guard index.item < unselectedMethods.count else {
            return
        }
        let method = unselectedMethods[index.item]
        methods.enumerated().forEach {
            if $0.element.sequence == method.sequence {
                selectedIndex = $0.offset
            }
        }
    }
    
    func deleteMethod(index: IndexPath) {
        guard index.item < unselectedMethods.count else {
            return
        }
        let method = unselectedMethods[index.item]
        methods.enumerated().reversed().forEach {
            if $0.element.sequence == method.sequence {
                methods.remove(at: $0.offset)
            }
        }
    }
}
