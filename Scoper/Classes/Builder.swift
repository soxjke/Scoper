//
//  Builder.swift
//  Scoper
//
//  Created by Petro Korienev on 4/7/18.
//

public protocol BuilderProtocol {
    associatedtype Result
    func build() -> Result
}
