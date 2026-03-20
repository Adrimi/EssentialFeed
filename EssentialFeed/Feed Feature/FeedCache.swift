//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 23/02/2021.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) async throws
}
