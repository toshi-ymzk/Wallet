//
//  BounceView.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/12/11.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit

class BounceView: UIView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
//            self.alpha = 0.9
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        bounce()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        bounce()
    }
    
    func bounce() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.transform = .identity // CGAffineTransform(scaleX: 1.01, y: 1.01)
//            self.alpha = 1
        }, completion: { _ in
//            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
//                self.transform = CGAffineTransform(scaleX: 0.99, y: 0.99)
//            }, completion: { _ in
//                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
//                    self.transform = .identity
//                })
//            })
        })
    }
}
