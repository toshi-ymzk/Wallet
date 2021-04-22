//
//  WalletViewModelA.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/05.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import Combine

class WalletViewModelA: ViewModelType {

    let useCase: WalletUseCase

    let cardRatio: CGFloat = 1 / 1.618
    let cellMargin: CGFloat = 30
    lazy var collectionViewHeight: CGFloat = floor(cellHeight + 60)
    lazy var cellWidth = UIScreen.main.bounds.width - cellMargin * 2
    lazy var cellHeight = floor(cellWidth * cardRatio)
    lazy var cellSize = CGSize(width: cellWidth, height: cellHeight)

    var paymentMethods = [PaymentMethodProtocol]()
    var currentPage: Int = 0

    private var currentOffsetX: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()

    enum Input {
        case viewDidLoad
        case scrollViewDidScroll(offsetX: CGFloat)
        case scrollViewWillEndDragging(velocityX: CGFloat, offsetPointer: UnsafeMutablePointer<CGPoint>)
        case scrollViewDidEndDragging(offsetX: CGFloat, decelerate: Bool)
        case scrollViewDidEndDecelerating(offsetX: CGFloat)
    }
    
    enum Output {
        case reload
        case transformCell(index: Int, transform: CGAffineTransform)
        case setPage(currentPage: Int, pageCount: Int)
        case setContentOffset(offsetX: CGFloat)
        case showError(Error)
    }

    @Published var output: Output?

    init(useCase: WalletUseCase) {
        self.useCase = useCase
    }
    
    func apply(input: Input) {
        switch input {
        case .viewDidLoad:
            getPaymentMethods()
        case .scrollViewDidScroll(let offsetX):
            let offsetDiff = abs(offsetX - currentOffsetX)
            currentOffsetX = offsetX
            transformCells()
            // Exclude big offset change caused by deceleration
            guard offsetDiff < 100 else {
                return
            }
            let page = targetPage(offsetX: offsetX)
            if currentPage != page {
                currentPage = page
                output = .setPage(currentPage: currentPage, pageCount: paymentMethods.count)
            }
        case .scrollViewWillEndDragging(let velocityX, let offsetPointer):
            offsetPointer.pointee.x = targetOffsetX(velocityX: velocityX, offsetX: offsetPointer.pointee.x)
        case .scrollViewDidEndDragging(let offsetX, let decelerate):
            if !decelerate {
                output = .setContentOffset(offsetX: targetOffsetX(offsetX: offsetX))
            }
        case .scrollViewDidEndDecelerating(let offsetX):
            output = .setContentOffset(offsetX: targetOffsetX(offsetX: offsetX))
        }
    }

    private func transformCells() {
        for i in 0..<paymentMethods.count {
            let scale: CGFloat = i == currentPage ? 1 : 0.9
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            output = .transformCell(index: i, transform: transform)
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
                    self?.output = .showError(err)
                }
            } receiveValue: { [weak self] methods in
                self?.paymentMethods = methods
                self?.output = .reload
                self?.output = .setPage(currentPage: 0, pageCount: methods.count)
            }.store(in: &cancellables)
    }

    private func targetOffsetX(velocityX: CGFloat = 0, offsetX: CGFloat) -> CGFloat {
        var page = currentPage
        if velocityX > 0 {
            page += 1
            if page >= paymentMethods.count {
                page = paymentMethods.count - 1
            }
        } else if velocityX < 0 {
            page -= 1
            if page < 0 {
                page = 0
            }
        } else {
            page = targetPage(offsetX: offsetX)
        }
        return cellWidth * CGFloat(page)
    }

    private func targetPage(offsetX: CGFloat) -> Int {
        let targetX = offsetX + cellWidth / 2
        return Int(floor(targetX / cellWidth))
    }
}
