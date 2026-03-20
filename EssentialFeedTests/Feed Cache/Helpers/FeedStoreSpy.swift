//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by adrian.szymanowski on 02/11/2020.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionContinuations = [CheckedContinuation<Void, Error>]()
    private var insertionContinuations = [CheckedContinuation<Void, Error>]()
    private var retrievalContinuations = [CheckedContinuation<CachedFeed?, Error>]()
    
    func deleteCachedFeed() async throws {
        receivedMessages.append(.deleteCachedFeed)
        try await withCheckedThrowingContinuation { continuation in
            deletionContinuations.append(continuation)
        }
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionContinuations[index].resume(throwing: error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionContinuations[index].resume(returning: ())
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionContinuations[index].resume(returning: ())
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) async throws {
        receivedMessages.append(.insert(feed, timestamp))
        try await withCheckedThrowingContinuation { continuation in
            insertionContinuations.append(continuation)
        }
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionContinuations[index].resume(throwing: error)
    }
    
    func retrieve() async throws -> CachedFeed? {
        receivedMessages.append(.retrieve)
        return try await withCheckedThrowingContinuation { continuation in
            retrievalContinuations.append(continuation)
        }
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalContinuations[index].resume(throwing: error)
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalContinuations[index].resume(returning: .none)
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalContinuations[index].resume(returning: CachedFeed(feed: feed, timestamp: timestamp))
    }
}
