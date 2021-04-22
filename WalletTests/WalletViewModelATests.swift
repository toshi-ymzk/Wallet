//
//  WalletViewModelATests.swift
//  WalletTests
//
//  Created by Toshihiro Yamazaki on 2021/04/22.
//

import XCTest
import UIKit
import Combine
@testable import Wallet

class WalletViewModelATests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    func testViewDidLoad() {
        let useCase = WalletUseCase(dataStore: WalletDataStore())
        let viewModel = WalletViewModelA(useCase: useCase)
        let exp = XCTestExpectation()
        exp.expectedFulfillmentCount = 2
        viewModel.$output.sink { output in
            guard let output = output else { return }
            switch output {
            case .reload:
                exp.fulfill()
            case .setPage(let currentPage, let pageCount):
                XCTAssertEqual(currentPage, 0)
                XCTAssertEqual(pageCount, 5)
                exp.fulfill()
            default:
                assertionFailure()
            }
        }.store(in: &cancellables)
        viewModel.apply(input: .viewDidLoad)
        wait(for: [exp], timeout: 1)
    }

    func testScrollViewDidScroll() {
        let useCase = WalletUseCase(dataStore: WalletDataStore())
        let viewModel = WalletViewModelA(useCase: useCase)
        let exp = XCTestExpectation()
        let currentPage = 1
        exp.expectedFulfillmentCount = 7
        viewModel.$output.sink { output in
            guard let output = output else { return }
            switch output {
            case .reload:
                exp.fulfill()
                viewModel.currentPage = currentPage
                viewModel.apply(input: .scrollViewDidScroll(offsetX: 0))
            case .transformCell(let index, let transform):
                let scale: CGFloat = index == currentPage ? 1 : 0.9
                XCTAssertEqual(transform.a, scale)
                XCTAssertEqual(transform.d, scale)
                exp.fulfill()
            case .setPage(let currentPage, let pageCount):
                XCTAssertEqual(currentPage, 0)
                XCTAssertEqual(pageCount, 5)
                exp.fulfill()
            default:
                break
            }
        }.store(in: &cancellables)
        viewModel.apply(input: .viewDidLoad)
        wait(for: [exp], timeout: 1)
    }
    
    func testScrollViewWillEndDragging() {
        let useCase = WalletUseCase(dataStore: WalletDataStore())
        let viewModel = WalletViewModelA(useCase: useCase)
        let exp = XCTestExpectation()
        viewModel.$output.sink { output in
            guard let output = output else { return }
            switch output {
            case .reload:
                var point = CGPoint(x: 300, y: 0)
                let pointer = UnsafeMutablePointer<CGPoint>(&point)
                viewModel.apply(input: .scrollViewWillEndDragging(velocityX: 0, offsetPointer: pointer))
                XCTAssertEqual(point.x, 330)
                viewModel.apply(input: .scrollViewWillEndDragging(velocityX: 1, offsetPointer: pointer))
                XCTAssertEqual(point.x, 330)
                viewModel.apply(input: .scrollViewWillEndDragging(velocityX: -1, offsetPointer: pointer))
                XCTAssertEqual(point.x, 0)
                exp.fulfill()
            default:
                break
            }
        }.store(in: &cancellables)
        viewModel.apply(input: .viewDidLoad)
        wait(for: [exp], timeout: 1)
    }

    func testScrollViewDidEndDragging() {
        let useCase = WalletUseCase(dataStore: WalletDataStore())
        let viewModel = WalletViewModelA(useCase: useCase)
        let exp = XCTestExpectation()
        exp.expectedFulfillmentCount = 2
        viewModel.$output.sink { output in
            guard let output = output else { return }
            switch output {
            case .reload:
                exp.fulfill()
                viewModel.apply(input: .scrollViewDidEndDragging(offsetX: 300, decelerate: false))
            case .setContentOffset(let offsetX):
                XCTAssertEqual(offsetX, 330)
                exp.fulfill()
            default:
                break
            }
        }.store(in: &cancellables)
        viewModel.apply(input: .viewDidLoad)
        wait(for: [exp], timeout: 1)
    }

    func testScrollViewDidEndDecelerating() {
        let useCase = WalletUseCase(dataStore: WalletDataStore())
        let viewModel = WalletViewModelA(useCase: useCase)
        let exp = XCTestExpectation()
        exp.expectedFulfillmentCount = 2
        viewModel.$output.sink { output in
            guard let output = output else { return }
            switch output {
            case .reload:
                exp.fulfill()
                viewModel.apply(input: .scrollViewDidEndDecelerating(offsetX: 300))
            case .setContentOffset(let offsetX):
                XCTAssertEqual(offsetX, 330)
                exp.fulfill()
            default:
                break
            }
        }.store(in: &cancellables)
        viewModel.apply(input: .viewDidLoad)
        wait(for: [exp], timeout: 1)
    }
}
