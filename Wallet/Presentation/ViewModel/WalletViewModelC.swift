//
//  WalletViewModelC.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/12.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import Combine

class WalletViewModelC: ViewModelType {

    let useCase: WalletUseCase

    let cardRatio: CGFloat = 1 / 1.618
    let cellSpace: CGFloat = 0

    let cardPosition = CGPoint(x: 80, y: 0)
    lazy var cardWidth = UIScreen.width - cardPosition.x + 20
    lazy var cardHeight = floor(cardWidth * cardRatio)

    var selectedIndex = 0

    var paymentMethods = [PaymentMethodProtocol]()
    
    private var cancellables = Set<AnyCancellable>()

    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case reload
        case showError(Error)
    }

    @Published var _output: Output?
    var output: Published<Output?>.Publisher {
        return $_output
    }
    
    init(useCase: WalletUseCase) {
        self.useCase = useCase
    }

    func apply(input: Input) {
        switch input {
        case .viewDidLoad:
            getPaymentMethods()
        }
    }

    private func getPaymentMethods() {
        useCase.getPaymentMethods()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let err):
                    self?._output = .showError(err)
                }
            } receiveValue: { [weak self] methods in
                self?.paymentMethods = methods
                self?._output = .reload
            }.store(in: &cancellables)
    }
}
