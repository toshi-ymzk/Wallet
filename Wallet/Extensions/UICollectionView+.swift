//
//  UICollectionView+.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/05.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func registerNib<T: UICollectionViewCell>(_ type: T.Type) {
        let nib = UINib(nibName: type.className, bundle: nil)
        register(nib, forCellWithReuseIdentifier: type.className)
    }
    
    func registerClass<T: UICollectionViewCell>(_ type: T.Type) {
        register(type, forCellWithReuseIdentifier: type.className)
    }
    
    func dequeueDefaultCell(indexPath: IndexPath) -> UICollectionViewCell {
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: "defaultCell")
        return dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath)
    }
}
