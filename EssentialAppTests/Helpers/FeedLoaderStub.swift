//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Adrian Szymanowski on 22/02/2021.
//

import Foundation
import EssentialFeed

class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
