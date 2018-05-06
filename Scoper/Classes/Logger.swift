//
//  Logger.swift
//  Scoper
//
//  Created by Petro Korienev on 5/6/18.
//

import Foundation

typealias Logger = (String) -> Void

func defaultLogger(message: String) {
    let date = Date()
    queue.async {
        asyncLogger(date: date, message: message)
    }
}

private let queue = DispatchQueue(label: "Scoper.Logger")
private let formatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "dd-MMM-yyy HH:mm:ss.SSS Z"
    return df
}()

private func asyncLogger(date: Date, message: String) {
    Swift.print("[" + formatter.string(from: date) + "] Scoper: " + message)
}
