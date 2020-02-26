//
//  CreditCardModel.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/05.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit

enum CreditCardType: String {
    case visa     = "VISA"
    case master   = "MASTER"
    case amex     = "AMEX"
    case jcb      = "JCB"
}

class CreditCardModel: Codable, PaymentMethodProtocol {
    
    var sequence  : Int    = -1
    var cardNumber: String = ""
    var cardType  : String = ""
    var cardBrand : String = ""
    var holderName: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case sequence = "card_seq"
        case cardNumber = "card_no"
        case cardType = "card_type"
        case cardBrand = "card_brand"
        case holderName = "holder_name"
    }
    
    var color: UIColor {
        if let type = CreditCardType(rawValue: self.cardType) {
            switch type {
            case .visa:
                let colors = [UIColor.hexColor(0x012C7D), UIColor.hexColor(0xF9B900)]
                return colors[sequence % 2]
            case .master:
                return UIColor.hexColor(0x333333)
            case .amex:
                return UIColor.hexColor(0x026FCF)
            case .jcb:
                return UIColor.hexColor(0x333333)
            }
        }
        return UIColor.clear
    }
    
    var logoImage: UIImage? {
        let prefix = "logo_"
        if let type = CreditCardType(rawValue: self.cardType) {
            switch type {
            case .visa    : return UIImage(named: prefix + "visa")
            case .master  : return UIImage(named: prefix + "master")
            case .amex    : return UIImage(named: prefix + "amex")
            case .jcb     : return UIImage(named: prefix + "jcb")
            }
        }
        return nil
    }
    
    required init(from decoder: Decoder) {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            return
        }
        sequence = (try? container.decode(Int.self, forKey: .sequence)) ?? -1
        cardNumber = (try? container.decode(String.self, forKey: .cardNumber)) ?? ""
        cardType = (try? container.decode(String.self, forKey: .cardType)) ?? ""
        cardBrand = (try? container.decode(String.self, forKey: .cardBrand)) ?? ""
        holderName = (try? container.decode(String.self, forKey: .holderName)) ?? ""
    }
}
