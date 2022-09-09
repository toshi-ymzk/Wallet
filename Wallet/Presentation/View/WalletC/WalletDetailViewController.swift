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

    private let viewModel: WalletDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    required init?(coder: NSCoder) {
        fatalError("--- init?(coder: NSCoder) has not been implemented ---")
    }

    init(args: WalletDetailViewModel.Argument) {
        viewModel = WalletDetailViewModel(args: args)
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        bind()
        viewModel.apply(input: .viewDidLoad)
    }

    private func setupView() {
        let top = UIScreen.statusBarHeight + UIScreen.navigationBarHeight
        scrollView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
        scrollView.addSubview(paymentMethodView)
    }

    private func bind() {
        viewModel.output.sink { [weak self] output in
            switch output {
            case .layoutPaymentMethodView(let method, let size):
                self?.paymentMethodView.layout(method: method, cardSize: size)
            case .none:
                break
            }
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
