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
        let message = formatMessage(date: date, message: message)
        guard message.count > 1000 else {
            NSLog(message)
            return
        }
        // Since iOS 10 Unified logging strips messages at around 1Kb of size
        message.split(separator: "\n").map { String($0) }.reduce([]) { arrayOfMessages, line -> [String] in
            if var currentMessage = arrayOfMessages.last {
                currentMessage.append("\n" + line)
                if currentMessage.count < 1000 {
                    return arrayOfMessages.dropLast() + [currentMessage]
                }
                else {
                    return arrayOfMessages + [line]
                }
            }
            else {
                return [line]
            }
        }.forEach { NSLog($0) }
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
