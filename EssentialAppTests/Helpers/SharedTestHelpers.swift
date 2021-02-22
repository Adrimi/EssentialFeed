//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Adrian Szymanowski on 18/02/2021.
//

import Foundation
import EssentialFeed

func anyData() -> Data {
    Data("any data".utf8)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com/")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
}
