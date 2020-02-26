//
//  UIColor+.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/05.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func hexColor(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            return hexColor(color, alpha: alpha)
        } else {
            return UIColor.clear
        }
    }
    
    static func hexColor(_ hex: UInt32, alpha: CGFloat = 1.0) -> UIColor {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255
        let green = CGFloat((hex & 0xFF00) >> 8) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
