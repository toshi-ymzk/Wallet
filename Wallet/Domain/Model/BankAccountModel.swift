//
//  BankAccountModel.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/05.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit

class BankAccountModel: Codable, PaymentMethodProtocol {
    
    var sequence: Int = -1
    var bankName: String = ""
    var branchName: String = ""
    var accountNumber: String = ""
    var accountItem: String = ""
    var logoURL: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case sequence = "bank_seq"
        case bankName = "bank_name"
        case branchName = "branch_name"
        case accountNumber = "account_number"
        case accountItem = "account_item"
        case logoURL = "logo_url"
    }
    
    var color: UIColor {
        switch bankName {
        default: break
        }
        return UIColor.darkGray
    }
    
    var logoImage: UIImage? {
        switch bankName {
        default: break
        }
        return nil
    }
    
    required init(from decoder: Decoder) {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            return
        }
        sequence = (try? container.decode(Int.self, forKey: .sequence)) ?? -1
        bankName = (try? container.decode(String.self, forKey: .bankName)) ?? ""
        branchName = (try? container.decode(String.self, forKey: .branchName)) ?? ""
        accountNumber = (try? container.decode(String.self, forKey: .accountNumber)) ?? ""
        accountItem = (try? container.decode(String.self, forKey: .accountItem)) ?? ""
        logoURL = (try? container.decode(String.self, forKey: .logoURL)) ?? ""
    }
}
