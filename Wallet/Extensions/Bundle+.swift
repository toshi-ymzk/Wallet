//
//  Bundle+.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/06.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import Foundation

extension Bundle {
    
    static func loadNib<T>(_ type: T.Type) -> T? {
        if let t = Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)?.first as? T {
            return t
        }
        return nil
    }
}
