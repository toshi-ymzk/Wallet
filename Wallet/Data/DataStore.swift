//
//  DataStore.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/06.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import Foundation

class DataStore {
    
    func loadStubData(name: String, type: String) -> [String : Any] {
        guard let path = Bundle.main.path(forResource: "Stub", ofType: "bundle"),
            let bundle = Bundle(path: path),
            let url = bundle.url(forResource: name, withExtension: type),
            let data = try? Data(contentsOf: url),
            let obj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let json = obj as? [String : Any] else {
                return [:]
        }
        return json
    }
    
    func parse<T: Decodable>(json: [String: Any]) -> T? {
        let decoder = JSONDecoder()
        guard let data = try? JSONSerialization.data(withJSONObject: json) else {
            return nil
        }
        return try? decoder.decode(T.self, from: data)
    }
    
    func parse<T: Decodable>(jsonArray: [[String: Any]]) -> [T] {
        let decoder = JSONDecoder()
        return jsonArray.compactMap {
            try? JSONSerialization.data(withJSONObject: $0)
        }.compactMap {
            try? decoder.decode(T.self, from: $0)
        }
    }
}
