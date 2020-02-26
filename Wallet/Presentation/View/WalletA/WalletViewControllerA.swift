//
//  WalletViewControllerA.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/06.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import RxSwift

class WalletViewControllerA: UIViewController {
    
    lazy var viewModel: WalletViewModelA = {
        let useCase = WalletUseCase(dataStore: WalletDataStore())
        let viewModel = WalletViewModelA(useCase: useCase)
        return viewModel
    }()
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
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
        collectionView.registerClass(WalletViewCellA.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionViewHeight.constant = viewModel.collectionViewHeight
        collectionView.reloadData()
        
        pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        bind()
        
        viewModel.getPaymentMethods()
    }
    
    private func bind() {
        viewModel.paymentMethods.bind { [weak self] _ in
            self?.collectionView.reloadData()
            self?.setPageControl(current: 0, count: self?.viewModel.pageCount ?? 0)
        }.disposed(by: disposeBag)
        
        viewModel.currentPage.bind { [weak self] page in
            self?.setPageControl(current: page, count: nil)
        }.disposed(by: disposeBag)
        
        viewModel.currentOffsetX.bind { [weak self] offsetX in
            self?.transformCells()
        }.disposed(by: disposeBag)
    }
    
    private func setPageControl(current: Int, count: Int?) {
        if let count = count {
            pageControl.numberOfPages = count
        }
        pageControl.currentPage = current
    }
    
    func transformCells() {
        for i in 0..<viewModel.pageCount {
            var transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            if i == viewModel.currentPage.value {
                transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    self.collectionView.cellForItem(at: IndexPath(item: i, section: 0))?.transform = transform
                })
            }
        }
    }
    
    @IBAction func dismiss() {
        dismiss(animated: true)
    }
}

extension WalletViewControllerA: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WalletViewCellA.className,
            for: indexPath) as? WalletViewCellA else {
                return collectionView.dequeueDefaultCell(indexPath: indexPath)
        }
        if indexPath.item < viewModel.paymentMethods.value.count {
            let method = viewModel.paymentMethods.value[indexPath.item]
            let cardSize = CGSize(width: viewModel.cellWidth, height: viewModel.cellHeight)
            cell.paymentMethodView.layout(method: method, cardSize: cardSize)
        }
        cell.transform = indexPath.item == viewModel.currentPage.value ?
            CGAffineTransform(scaleX: 1, y: 1) : CGAffineTransform(scaleX: 0.9, y: 0.9)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sectionCount
    }
}

extension WalletViewControllerA: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: viewModel.cellWidth, height: viewModel.cellHeight)
    }
}

extension WalletViewControllerA: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetDiff = abs(scrollView.contentOffset.x - viewModel.currentOffsetX.value)
        viewModel.currentOffsetX.accept(scrollView.contentOffset.x)
        let threshold = viewModel.cellWidth + viewModel.cellSpace
        // Exclude big offset change caused by deceleration
        if offsetDiff < 100 {
            // Calculate target page
            let targetX = scrollView.contentOffset.x + threshold / 2
            let page = Int(floor(targetX / threshold))
            if viewModel.currentPage.value != page {
                viewModel.currentPage.accept(page)
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let threshold = viewModel.cellWidth + viewModel.cellSpace
        var page = viewModel.currentPage.value
        if velocity.x > 0 {
            page += 1
            if page >= viewModel.pageCount {
                page = viewModel.pageCount - 1
            }
        } else if velocity.x < 0 {
            page -= 1
            if page < 0 {
                page = 0
            }
        } else {
            let targetX = targetContentOffset.pointee.x + threshold / 2
            page = Int(floor(targetX / threshold))
        }
        targetContentOffset.pointee.x = threshold * CGFloat(page)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            let threshold = viewModel.cellWidth + viewModel.cellSpace
            let targetX = scrollView.contentOffset.x + threshold / 2
            let page = Int(floor(targetX / threshold))
            scrollView.setContentOffset(CGPoint(x: threshold * CGFloat(page), y: 0), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let threshold = viewModel.cellWidth + viewModel.cellSpace
        let targetX = scrollView.contentOffset.x + threshold / 2
        let page = Int(floor(targetX / threshold))
        scrollView.setContentOffset(CGPoint(x: threshold * CGFloat(page), y: 0), animated: true)
    }
}
