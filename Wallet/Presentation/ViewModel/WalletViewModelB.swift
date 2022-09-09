//
//  WalletViewModelB.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/06.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import Combine

class WalletViewModelB: ViewModelType {

    let useCase: WalletUseCase

    let cardRatio: CGFloat = 1 / 1.618
    let cellSpace: CGFloat = 16
    let sectionInset: CGFloat = 16
    lazy var cellWidth = (UIScreen.main.bounds.width - sectionInset * 2 - cellSpace) / 2
    lazy var cellHeight = floor(cellWidth * cardRatio)
    lazy var cellSize = CGSize(width: cellWidth, height: cellHeight)

    lazy var selectedMethodViewWidth = UIScreen.main.bounds.width - sectionInset * 2
    lazy var selectedMethodViewHeight = floor(selectedMethodViewWidth * cardRatio)

    var selectedIndex = 0

    var itemCount: Int {
        return unselectedMethods.count
    }
    
    var unselectedMethods: [PaymentMethodProtocol] {
        return paymentMethods.enumerated()
            .filter({ $0.offset != selectedIndex })
            .map({ $0.element })
    }

    var paymentMethods = [PaymentMethodProtocol]()
    @Published var paymentMethodError = NSError() as Error

    var cellDidAppear: Bool = false
    
    private var cancellables = Set<AnyCancellable>()

    enum Input {
        case viewDidLoad
        case selectMethod(index: IndexPath)
        case deleteMethod(index: IndexPath)
    }
    
    enum Output {
        case reload
        case layoutSelectedMethodView(previous: PaymentMethodProtocol?, current: PaymentMethodProtocol?)
        case deleteCell(index: IndexPath)
        case replaceCell(deleteIndex: IndexPath, insertIndex: IndexPath)
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
        case .selectMethod(let index):
            selectMethod(index: index)
        case .deleteMethod(let index):
            deleteMethod(index: index)
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
                    self?.paymentMethodError = err
                }
            } receiveValue: { [weak self] methods in
                self?.paymentMethods = methods
                if let method = methods.first {
                    self?._output = .layoutSelectedMethodView(previous: nil, current: method)
                }
                self?._output = .reload
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(methods.count) * 0.1) {
                    self?.cellDidAppear = true
                }
            }.store(in: &cancellables)
    }

    func selectMethod(index: IndexPath) {
        guard index.item < unselectedMethods.count else {
            return
        }
        let insertIndex = IndexPath(item: selectedIndex <= index.item ? selectedIndex : selectedIndex - 1, section: 0)
        let method = unselectedMethods[index.item]
        paymentMethods.enumerated().forEach {
            if $0.element.sequence == method.sequence {
                let previousIndex = selectedIndex
                selectedIndex = $0.offset
                _output = .layoutSelectedMethodView(previous: paymentMethods[previousIndex], current: paymentMethods[selectedIndex])
                _output = .replaceCell(deleteIndex: index, insertIndex: insertIndex)
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
                _output = .deleteCell(index: index)
            }
        }
    }
}
