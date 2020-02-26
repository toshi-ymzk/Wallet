//
//  WalletDataStore.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/06.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import Foundation

class WalletDataStore: DataStore {
    
    func getPaymentMethods(success: @escaping (PaymentMethodEntity) -> Void,
                           failure: @escaping (Error) -> Void) {
        let json = loadStubData(name: "payment_methods", type: "json")
        if let entity: PaymentMethodEntity = parse(json: json) {
            success(entity)
        } else {
            failure(NSError(domain: "", code: 0, userInfo: nil))
        }
    }
}
