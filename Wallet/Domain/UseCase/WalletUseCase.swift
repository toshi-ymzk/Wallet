//
//  WalletUseCase.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/06.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import Combine

class WalletUseCase {
    
    let dataStore: WalletDataStore
    
    init(dataStore: WalletDataStore) {
        self.dataStore = dataStore
    }
    
    func getPaymentMethods() -> AnyPublisher<[PaymentMethodProtocol], Error> {
        return Deferred { [weak self] in
            Future { promise in
                self?.dataStore.getPaymentMethods(success: { res in
                    let methods = /*res.bankAccounts as [PaymentMethodProtocol] +*/ res.creditCards as [PaymentMethodProtocol]
                    promise(.success(methods))
                }, failure: { err in
                    promise(.failure(err))
                })
            }
        }.eraseToAnyPublisher()
    }
}
