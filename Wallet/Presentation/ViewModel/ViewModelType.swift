//
//  ViewModelType.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2021/04/21.
//

import Foundation
import Combine

public protocol ViewModelType {

    associatedtype Input
    func apply(input: Input)

    associatedtype Output
    var output: Published<Output?>.Publisher { get }
}
