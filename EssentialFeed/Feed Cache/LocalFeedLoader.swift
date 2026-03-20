//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by adrian.szymanowski on 01/11/2020.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

// MARK: - Save extension
extension LocalFeedLoader: FeedCache {
    public func save(_ feed: [FeedImage]) async throws {
        try await store.deleteCachedFeed()
        try await cache(feed)
    }
    
    private func cache(_ items: [FeedImage]) async throws {
        try await store.insert(items.toLocal(), timestamp: currentDate())
    }
}

// MARK: - Load extension
extension LocalFeedLoader {
    public func load() async throws -> [FeedImage] {
        switch try await store.retrieve() {
        case let .some(cache) where FeedCachePolicy.validate(cache.timestamp, against: currentDate()):
            return cache.feed.toModels()

        case .some, .none:
            return []
        }
    }
}

// MARK: - Validate extension
extension LocalFeedLoader {
    public func validateCache() async throws {
        do {
            if let cache = try await store.retrieve(),
               !FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                try await store.deleteCachedFeed()
            }
        } catch {
            try await store.deleteCachedFeed()
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map {
            LocalFeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
            )
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map {
            FeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
            )
        }
    }
}
