//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Adrian Szymanowski on 13/02/2021.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieve(dataFor: URL)
    }
    
    private(set) var receivedMessages = [Message]()
    private var retrievalContinuations = [CheckedContinuation<Data?, Error>]()
    private var insertionContinuations = [CheckedContinuation<Void, Error>]()
    
    func insert(_ data: Data, for url: URL) async throws {
        receivedMessages.append(.insert(data: data, for: url))
        try await withCheckedThrowingContinuation { continuation in
            insertionContinuations.append(continuation)
        }
    }
    
    func retrieve(dataForURL url: URL) async throws -> Data? {
        receivedMessages.append(.retrieve(dataFor: url))
        return try await withCheckedThrowingContinuation { continuation in
            retrievalContinuations.append(continuation)
        }
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalContinuations[index].resume(throwing: error)
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalContinuations[index].resume(returning: data)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionContinuations[index].resume(throwing: error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionContinuations[index].resume(returning: ())
    }
}
