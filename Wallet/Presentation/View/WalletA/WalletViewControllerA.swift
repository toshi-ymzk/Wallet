//
//  WalletViewControllerA.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/06.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import Combine

class WalletViewControllerA: UIViewController {

    lazy var viewModel: WalletViewModelA = {
        let useCase = WalletUseCase(dataStore: WalletDataStore())
        let viewModel = WalletViewModelA(useCase: useCase)
        return viewModel
    }()

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!

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
        collectionView.registerClass(WalletViewCellA.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionViewHeight.constant = viewModel.collectionViewHeight
        collectionView.reloadData()

        pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }

    private func bind() {
        viewModel.$output.sink { [weak self] output in
            guard let output = output else { return }
            switch output {
            case .reload:
                self?.collectionView.reloadData()
            case .transformCell(let index, let transform):
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                        self?.collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.transform = transform
                    })
                }
            case .setPage(let currentPage, let pageCount):
                self?.pageControl.numberOfPages = pageCount
                self?.pageControl.currentPage = currentPage
            case .setContentOffset(let offsetX):
                self?.collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
            case .showError(let err):
                let alert = UIAlertController(title: nil, message: err.localizedDescription, preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true)
            }
        }.store(in: &cancellables)
    }

    @IBAction func dismiss() {
        dismiss(animated: true)
    }
}

extension WalletViewControllerA: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.paymentMethods.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WalletViewCellA.className, for: indexPath) as? WalletViewCellA,
              indexPath.item < viewModel.paymentMethods.count else {
                return collectionView.dequeueDefaultCell(indexPath: indexPath)
        }
        let method = viewModel.paymentMethods[indexPath.item]
        cell.paymentMethodView.layout(method: method, cardSize: viewModel.cellSize)
        let scale: CGFloat = indexPath.item == viewModel.currentPage ? 1 : 0.9
        cell.transform = CGAffineTransform(scaleX: scale, y: scale)
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension WalletViewControllerA: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.cellSize
    }
}

extension WalletViewControllerA: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel.apply(input: .scrollViewDidScroll(offsetX: scrollView.contentOffset.x))
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        viewModel.apply(input: .scrollViewWillEndDragging(velocityX: velocity.x, offsetPointer: targetContentOffset))
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        viewModel.apply(input: .scrollViewDidEndDragging(offsetX: scrollView.contentOffset.x, decelerate: decelerate))
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        viewModel.apply(input: .scrollViewDidEndDecelerating(offsetX: scrollView.contentOffset.x))
    }
}
