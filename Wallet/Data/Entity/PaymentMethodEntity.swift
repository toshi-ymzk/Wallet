//
//  PaymentMethodEntity.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/06.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

class PaymentMethodEntity: Codable {
    
    var creditCards : [CreditCardModel]  = []
    var bankAccounts: [BankAccountModel] = []
    var maxBanks    : Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case creditCards = "credit_cards"
        case bankAccounts = "bank_accounts"
        case maxBanks = "bank_account_max_limit"
    }
    
    required init(from decoder: Decoder) {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            return
        }
        creditCards = (try? container.decode([CreditCardModel].self, forKey: .creditCards)) ?? []
        bankAccounts = (try? container.decode([BankAccountModel].self, forKey: .bankAccounts)) ?? []
        maxBanks = (try? container.decode(Int.self, forKey: .maxBanks)) ?? 0
    }
}
