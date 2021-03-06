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
    
    private var deletionCompletion = [DeletionCompletion]()
    private var insertionCompeltions = [InsertionCompletion]()
    private var retrievalCompeltions = [RetrievalCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletion.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletion[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletion[index](.success(()))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompeltions[index](.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompeltions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompeltions[index](.failure(error))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompeltions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompeltions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompeltions[index](.success(.none))
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalCompeltions[index](.success(CachedFeed(feed: feed, timestamp: timestamp)))
    }
}
