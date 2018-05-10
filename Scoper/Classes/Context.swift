//
//  Context.swift
//  Scoper
//
//  Created by Petro Korienev on 4/7/18.
//

public class Context<KeyType: CustomStringConvertible> {
    private var innerDictionary: [String: Any] = [:]
    public func put<T>(value: T, `for` key: KeyType) {
        innerDictionary[key.description] = value
    }
    public func getValue<T>(`for` key: KeyType) -> T? {
        return innerDictionary[key.description] as? T
    }
    public subscript<T>(key: KeyType) -> T? {
        get {
            return getValue(for: key)
        }
        set(value) {
            put(value: value, for: key)
        }
    }
}

typealias DefaultContext = Context<String>
