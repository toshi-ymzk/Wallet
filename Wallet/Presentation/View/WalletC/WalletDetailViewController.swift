//
//  WalletDetailViewController.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/12.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit
import Combine

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
    
    private var cancellables = Set<AnyCancellable>()
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
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
        viewModel.$paymentMethod.sink { [weak self] method in
            self?.paymentMethodView.layout(method: method, cardSize: cardSize)
        }.store(in: &cancellables)
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
