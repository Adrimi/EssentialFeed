//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 23/02/2021.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
