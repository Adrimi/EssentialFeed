//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 15/02/2021.
//

import CoreData

extension CoreDataFeedStore: FeedStore {
    public func retrieve() async throws -> CachedFeed? {
        try await perform { context in
            try ManagedCache.find(in: context).map {
                CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date) async throws {
        try await perform { context in
            let managedCache = try ManagedCache.newUniqueInstance(in: context)
            managedCache.timestamp = timestamp
            managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
            try context.save()
        }
    }
    
    public func deleteCachedFeed() async throws {
        try await perform { context in
            try ManagedCache.deleteCache(in: context)
        }
    }

}
