//
//  WalletViewModelC.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/12.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import Combine

class WalletViewModelC {
    
    let useCase: WalletUseCase
    
    let cardRatio: CGFloat = 1 / 1.618
    let cellSpace: CGFloat = 0
    
    let cardPosition = CGPoint(x: 80, y: 0)
    lazy var cardWidth = UIScreen.width - cardPosition.x + 20
    lazy var cardHeight = floor(cardWidth * cardRatio)
    
    let sectionCount: Int = 1
    var selectedIndex = 0
    
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
            }.store(in: &cancellables)
    }
}
