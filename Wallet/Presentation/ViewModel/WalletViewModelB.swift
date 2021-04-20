//
//  WalletViewModelB.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/06.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import Combine

class WalletViewModelB {
    
    let useCase: WalletUseCase
    
    let cardRatio: CGFloat = 1 / 1.618
    let cellSpace: CGFloat = 16
    let sectionInset: CGFloat = 16
    lazy var cellWidth = (UIScreen.main.bounds.width - sectionInset * 2 - cellSpace) / 2
    lazy var cellHeight = floor(cellWidth * cardRatio)
    
    lazy var selectedMethodViewWidth = UIScreen.main.bounds.width - sectionInset * 2
    lazy var selectedMethodViewHeight = floor(selectedMethodViewWidth * cardRatio)
    
    var selectedIndex = 0 {
        didSet {
            selectedMethod = (selectedMethod.1, paymentMethods[selectedIndex])
        }
    }
    
    var itemCount: Int {
        return unselectedMethods.count
    }
    let sectionCount: Int = 1
    
    var unselectedMethods: [PaymentMethodProtocol] {
        return paymentMethods.enumerated()
            .filter({ $0.offset != selectedIndex })
            .map({ $0.element })
    }
    
    @Published var selectedMethod: (PaymentMethodProtocol?, PaymentMethodProtocol?) = (nil, nil)
    @Published var paymentMethods = [PaymentMethodProtocol]()
    @Published var paymentMethodError = NSError() as Error
    
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: WalletUseCase) {
        self.useCase = useCase
    }
    
    func getPaymentMethods() {
        useCase.getPaymentMethods()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let err):
                    self?.paymentMethodError = err
                }
            } receiveValue: { [weak self] methods in
                self?.paymentMethods = methods
                if let method = methods.first {
                    self?.selectedMethod = (self?.selectedMethod.0, method)
                }
            }.store(in: &cancellables)
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
        paymentMethods.enumerated().forEach {
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
        paymentMethods.enumerated().reversed().forEach {
            if $0.element.sequence == method.sequence {
                paymentMethods.remove(at: $0.offset)
            }
        }
    }
}
