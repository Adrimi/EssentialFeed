//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by adrian.szymanowski on 01/11/2020.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    func deleteCachedFeed() async throws
    func insert(_ feed: [LocalFeedImage], timestamp: Date) async throws
    func retrieve() async throws -> CachedFeed?
}
