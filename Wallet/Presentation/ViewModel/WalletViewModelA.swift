//
//  WalletViewModelA.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/05.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import Combine

class WalletViewModelA {
    
    let useCase: WalletUseCase
    
    let cardRatio: CGFloat = 1 / 1.618
    let cellSpace: CGFloat = 0
    let cellMargin: CGFloat = 30
    let collectionViewMargin: CGFloat = 30
    lazy var collectionViewHeight: CGFloat = floor(cellHeight + 60)
    lazy var cellWidth = UIScreen.main.bounds.width - cellMargin * 2
    lazy var cellHeight = floor(cellWidth * cardRatio)
    
    @Published var paymentMethods = [PaymentMethodProtocol]()
    @Published var paymentMethodError = NSError() as Error
    @Published var currentOffsetX: CGFloat = 0
    @Published var currentPage: Int = 0
    var pageCount: Int {
        return paymentMethods.count
    }
    let sectionCount: Int = 1
    
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
            }.store(in: &cancellables)
    }
}
