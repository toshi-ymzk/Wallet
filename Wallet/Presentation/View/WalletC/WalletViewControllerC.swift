//
//  WalletViewControllerC.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/12.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import Combine

class WalletViewControllerC: UIViewController {
    
    lazy var viewModel: WalletViewModelC = {
        let useCase = WalletUseCase(dataStore: WalletDataStore())
        let viewModel = WalletViewModelC(useCase: useCase)
        return viewModel
    }()
    
    @IBOutlet var collectionView: UICollectionView!
    
    private var cancellables = Set<AnyCancellable>()
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        let top = UIScreen.statusBarHeight + UIScreen.navigationBarHeight
        collectionView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
        collectionView.registerClass(WalletCellC.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        bind()
        
        viewModel.getPaymentMethods()
    }
    
    private func bind() {
        viewModel.$paymentMethods.sink { [weak self] methods in
            self?.collectionView.reloadData()
        }.store(in: &cancellables)
    }
    
    @IBAction func dismiss() {
        dismiss(animated: true)
    }
}

extension WalletViewControllerC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.paymentMethods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WalletCellC.className, for: indexPath) as? WalletCellC else {
                return collectionView.dequeueDefaultCell(indexPath: indexPath)
        }
        if indexPath.item < viewModel.paymentMethods.count {
            let method = viewModel.paymentMethods[indexPath.item]
            let cardSize = CGSize(width: viewModel.cardWidth, height: viewModel.cardHeight)
            cell.layout(method: method, cardSize: cardSize, cardPosition: viewModel.cardPosition)
        }
        cell.frame.origin.y = CGFloat(indexPath.item) * (viewModel.cardHeight - 120)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sectionCount
    }
}

extension WalletViewControllerC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: viewModel.cardHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < viewModel.paymentMethods.count else {
            return
        }
        viewModel.selectedIndex = indexPath.item
        let method = viewModel.paymentMethods[indexPath.item]
        let vm = WalletDetailViewModel(paymentMethod: method)
        let vc = WalletDetailViewController()
        vc.viewModel = vm
        vc.transitioningDelegate = vc
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

extension WalletViewControllerC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
}
