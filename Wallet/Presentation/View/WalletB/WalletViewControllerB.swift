//
//  WalletViewControllerB.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/06.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import RxSwift

class WalletViewControllerB: UIViewController {
    
    lazy var viewModel: WalletViewModelB = {
        let useCase = WalletUseCase(dataStore: WalletDataStore())
        let viewModel = WalletViewModelB(useCase: useCase)
        return viewModel
    }()
    
    @IBOutlet var selectedMethodView: PaymentMethodView!
    @IBOutlet var collectionView: UICollectionView!
    
    var collectionViewDidAppeared = false
    
    private let disposeBag = DisposeBag()
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return .darkContent
        }
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        collectionView.registerClass(WalletViewCellB.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.delaysContentTouches = false
        collectionView.contentInset = .zero
        collectionView.reloadData()
        collectionView.alpha = 0
        selectedMethodView.alpha = 0
        
        bind()
        
        viewModel.getPaymentMethods()
    }
    
    private func bind() {
        viewModel.paymentMethods
            .share(replay: 1, scope: .whileConnected)
            .subscribe(onNext: { [weak self] methods in
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    UIView.animate(withDuration: 10, delay: 0, options: .curveEaseInOut, animations: {
                        self?.collectionView.alpha = 1
                        self?.selectedMethodView.alpha = 1
                    }, completion: { _ in
                        self?.collectionViewDidAppeared = true
                    })
                }
            }).disposed(by: disposeBag)
        
        Observable.zip(viewModel.selectedMethod.skip(1), viewModel.selectedMethod)
            .share(replay: 1, scope: .whileConnected)
            .subscribe(onNext: { [weak self] methods in
                let (current, previous) = methods
                guard let s = self, let method = current else { return }
                let cardSize = CGSize(width: s.viewModel.selectedMethodViewWidth, height: s.viewModel.selectedMethodViewHeight)
                DispatchQueue.main.async {
                    self?.selectedMethodView.layoutWithAnimation(method: method,
                                                                 previousMethod: previous,
                                                                 cardSize: cardSize,
                                                                 fontSize: 20)
                    self?.collectionView.reloadData()
                }
            }).disposed(by: disposeBag)
    }
    
    private func showCellWithAnimation(cell: UICollectionViewCell, indexPath: IndexPath) {
        cell.alpha = 0
        cell.frame.origin.y += 10
        let delay = TimeInterval(CGFloat(indexPath.item) * 0.1)
        UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseInOut, animations: {
            cell.alpha = 1
            cell.frame.origin.y -= 10
        })
    }
    
    private func replaceCell(index: IndexPath) {
        let insertIndex = viewModel.getInsertIndex(index: index)
        collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: [index])
            self.viewModel.setSelectedIndex(index: index)
            self.collectionView.insertItems(at: [insertIndex])
        })
    }
    
    private func deleteCell(index: IndexPath) {
        collectionView.performBatchUpdates({
            self.viewModel.deleteMethod(index: index)
            self.collectionView.deleteItems(at: [index])
        })
    }
    
    @IBAction func dismiss() {
        dismiss(animated: true)
    }
}

extension WalletViewControllerB: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WalletViewCellB.className, for: indexPath) as? WalletViewCellB else {
                return collectionView.dequeueDefaultCell(indexPath: indexPath)
        }
        if indexPath.item < viewModel.unselectedMethods.count {
            let method = viewModel.unselectedMethods[indexPath.item]
            let cardSize = CGSize(width: viewModel.cellWidth, height: viewModel.cellHeight)
            cell.paymentMethodView.layout(method: method,
                                          cardSize: cardSize,
                                          fontSize: 12)
        }
        if !self.collectionViewDidAppeared {
            showCellWithAnimation(cell: cell, indexPath: indexPath)
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sectionCount
    }
}

extension WalletViewControllerB: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: viewModel.cellWidth, height: viewModel.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let alert = UIAlertController(title: "Payment Method", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Set as a Default Card", style: .default, handler: { [weak self] _ in
            self?.replaceCell(index: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteCell(index: indexPath)
        }))
        present(alert, animated: true)
    }
}

extension WalletViewControllerB: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 0 {
            scrollView.setContentOffset(.zero, animated: false)
        }
    }
}
