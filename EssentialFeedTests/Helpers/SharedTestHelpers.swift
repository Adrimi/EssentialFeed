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

