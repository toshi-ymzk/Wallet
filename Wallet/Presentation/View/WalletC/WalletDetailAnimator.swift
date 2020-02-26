//
//  WalletDetailAnimator.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/14.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit

class WalletDetailPresentedAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? WalletDetailViewController,
            let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? WalletViewControllerC,
            let selectedCell = from.collectionView.cellForItem(at: IndexPath(item: from.viewModel.selectedIndex, section: 0)) as? WalletCellC else {
                return
        }
        let duration = 0.3
        var delay: Double = 0.0
        let originalFrame = selectedCell.frame
        for (i, cell) in from.collectionView.visibleCells.enumerated() {
            guard i != from.viewModel.selectedIndex else { continue }
            cell.alpha = 1
            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
                cell.alpha = 0
                (cell as? WalletCellC)?.paymentMethodView.rotate(angle: 0)
                cell.frame.origin.y -= 300
            })
            delay += 0.05
        }
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
            let y = to.paymentMethodView.convert(to.paymentMethodView.bounds, to: from.collectionView).origin.y + UIScreen.navigationBarHeight
            selectedCell.frame.origin.y = y
            selectedCell.paymentMethodView.rotate(angle: 0)
        }) { _ in
            selectedCell.frame = originalFrame
            to.view.frame = transitionContext.finalFrame(for: to)
            transitionContext.containerView.addSubview(to.view)
            transitionContext.completeTransition(true)
        }
    }
}

class WalletDetailDismissedAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? WalletViewControllerC,
            let selectedCell = to.collectionView.cellForItem(at: IndexPath(item: to.viewModel.selectedIndex, section: 0)) as? WalletCellC else {
                return
        }
        to.view.frame = transitionContext.finalFrame(for: to)
        transitionContext.containerView.addSubview(to.view)

        let duration = 0.3
        var delay: Double = 0.05
        for (i, cell) in to.collectionView.visibleCells.enumerated().reversed() {
            guard i != to.viewModel.selectedIndex else { continue }
            cell.alpha = 0
            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
                cell.alpha = 1
                (cell as? WalletCellC)?.paymentMethodView.rotate(angle: -0.25 * CGFloat.pi)
                cell.frame.origin.y += 300
            })
            delay += 0.05
        }
        let originalFrame = selectedCell.frame
        selectedCell.frame.origin.y = 0
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
            selectedCell.frame.origin.y = originalFrame.origin.y
            selectedCell.paymentMethodView.rotate(angle: -0.25 * CGFloat.pi)
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
}
