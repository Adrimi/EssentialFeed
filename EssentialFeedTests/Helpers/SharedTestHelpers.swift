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
    
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian)
            .date(
                byAdding: .day,
                value: days,
                to: self)!
    }
    
    func adding(minutes: Int) -> Date {
        Calendar(identifier: .gregorian)
            .date(
                byAdding: .minute,
                value: minutes,
                to: self)!
    }
}
