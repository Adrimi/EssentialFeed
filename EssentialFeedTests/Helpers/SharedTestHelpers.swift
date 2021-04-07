//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by adrian.szymanowski on 06/11/2020.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com/")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
    
    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        calendar.date(
            byAdding: .day,
            value: days,
            to: self)!
    }
    
    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        calendar.date(
            byAdding: .minute,
            value: minutes,
            to: self)!
    }
}
