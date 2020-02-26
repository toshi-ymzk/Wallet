//
//  WalletUseCase.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/06.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import RxSwift

class WalletUseCase {
    
    let dataStore: WalletDataStore
    
    init(dataStore: WalletDataStore) {
        self.dataStore = dataStore
    }
    
    func getPaymentMethods() -> Single<[PaymentMethodProtocol]> {
        return Single<[PaymentMethodProtocol]>.create(subscribe: { [weak self] observer -> Disposable in
            self?.dataStore.getPaymentMethods(success: { res in
                let methods = /*res.bankAccounts as [PaymentMethodProtocol] +*/ res.creditCards as [PaymentMethodProtocol]
                observer(.success(methods))
            }, failure: { err in
                observer(.error(err))
            })
            return Disposables.create()
        })
    }
}
