//
//  UIScreen+.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/14.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit

extension UIScreen {
    
    static var width: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    static var height: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    static var statusBarHeight: CGFloat {
        return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20
    }
    
    static var navigationBarHeight: CGFloat {
        return 44
    }
}
