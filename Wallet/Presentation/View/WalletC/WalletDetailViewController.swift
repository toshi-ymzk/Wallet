//
//  WalletDetailViewController.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/12.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WalletDetailViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollViewBottom: NSLayoutConstraint!
    
    lazy var paymentMethodView: PaymentMethodView = {
        let x = CGFloat(80)
        let width = UIScreen.width - x + 20
        let height = floor(width / PaymentMethodView.cardRatio)
        let methodView = PaymentMethodView(frame: CGRect(x: x, y: 0, width: width, height: height))
        return methodView
    }()
    
    var viewModel: WalletDetailViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            subscribe(viewModel: viewModel)
        }
    }
    
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
    
    func setupView() {
        let top = UIScreen.statusBarHeight + UIScreen.navigationBarHeight
        scrollView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
        scrollView.addSubview(paymentMethodView)
    }
    
    func subscribe(viewModel: WalletDetailViewModel) {
        let cardSize = CGSize(width: viewModel.cardWidth, height: viewModel.cardHeight)
        viewModel.paymentMethod.drive(onNext: { [weak self] method in
            self?.paymentMethodView.layout(method: method, cardSize: cardSize)
        }).disposed(by: disposeBag)
    }
    
    @IBAction func dismiss() {
        dismiss(animated: true)
    }
}

extension WalletDetailViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return WalletDetailPresentedAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return WalletDetailDismissedAnimator()
    }
}
