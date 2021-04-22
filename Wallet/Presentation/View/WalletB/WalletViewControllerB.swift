//
//  WalletViewControllerB.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/06.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import Combine

class WalletViewControllerB: UIViewController {

    lazy var viewModel: WalletViewModelB = {
        let useCase = WalletUseCase(dataStore: WalletDataStore())
        let viewModel = WalletViewModelB(useCase: useCase)
        return viewModel
    }()

    @IBOutlet var selectedMethodView: PaymentMethodView!
    @IBOutlet var collectionView: UICollectionView!

    private var cancellables = Set<AnyCancellable>()

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bind()
        viewModel.apply(input: .viewDidLoad)
    }

    private func setupView() {
        collectionView.registerClass(WalletViewCellB.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.delaysContentTouches = false
        collectionView.contentInset = .zero
        collectionView.reloadData()
    }

    private func bind() {
        viewModel.$output.sink { [weak self] output in
            guard let output = output else { return }
            switch output {
            case .reload:
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .layoutSelectedMethodView(let previous, let current):
                guard let s = self, let method = current else { return }
                let cardSize = CGSize(width: s.viewModel.selectedMethodViewWidth, height: s.viewModel.selectedMethodViewHeight)
                DispatchQueue.main.async {
                    self?.selectedMethodView.layoutWithAnimation(method: method,
                                                                 previousMethod: previous,
                                                                 cardSize: cardSize,
                                                                 fontSize: 20)
                }
            case .deleteCell(let index):
                self?.collectionView.performBatchUpdates({
                    self?.collectionView.deleteItems(at: [index])
                })
            case .replaceCell(let deleteIndex, let insertIndex):
                self?.collectionView.performBatchUpdates({
                    self?.collectionView.deleteItems(at: [deleteIndex])
                    self?.collectionView.insertItems(at: [insertIndex])
                })
            }
        }.store(in: &cancellables)
    }

    private func animateCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        DispatchQueue.main.async {
            cell.alpha = 0
            cell.frame.origin.y += 10
            let delay = TimeInterval(CGFloat(indexPath.item) * 0.1)
            UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseInOut, animations: {
                cell.alpha = 1
                cell.frame.origin.y -= 10
            })
        }
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WalletViewCellB.className, for: indexPath) as? WalletViewCellB,
              indexPath.item < viewModel.unselectedMethods.count else {
                return collectionView.dequeueDefaultCell(indexPath: indexPath)
        }
        let method = viewModel.unselectedMethods[indexPath.item]
        cell.paymentMethodView.layout(method: method, cardSize: viewModel.cellSize, fontSize: 12)
        if !self.viewModel.cellDidAppear {
            animateCell(cell: cell, indexPath: indexPath)
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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
            self?.viewModel.apply(input: .selectMethod(index: indexPath))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.apply(input: .deleteMethod(index: indexPath))
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
