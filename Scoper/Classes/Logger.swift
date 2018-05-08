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
        Swift.print(formatMessage(date: date, message: message))
    }
}

private let queue = DispatchQueue(label: "Scoper.Logger")
private let formatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "dd-MMM-yyy HH:mm:ss.SSS Z"
    return df
}()

func formatMessage(date: Date, message: String) -> String {
    return "[" + formatter.string(from: date) + "] Scoper: " + message
}
