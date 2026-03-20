//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by adrian.szymanowski on 02/11/2020.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetreieval() async {
        let (sut, store) = makeSUT()
        
        let task = Task {
            try? await sut.load()
        }
        await Task.yield()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
        store.completeRetrievalWithEmptyCache()
        _ = await task.result
    }
    
    func test_load_failsOnRetreievalError() async {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        await expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache() async {
        let (sut, store) = makeSUT()
        
        await expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedImagesOnNoExpiredChache() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let noExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
            
        
        await expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.local, timestamp: noExpiredTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnChacheExpiration() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
            
        
        await expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnExpiredChache() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
            
        await expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        }
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() async {
        let (sut, store) = makeSUT()
        
        let task = Task {
            try? await sut.load()
        }
        await Task.yield()
        store.completeRetrieval(with: anyNSError())
        _ = await task.result
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() async {
        let (sut, store) = makeSUT()
        
        let task = Task {
            try? await sut.load()
        }
        await Task.yield()
        store.completeRetrievalWithEmptyCache()
        _ = await task.result
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnNoExpiredCache() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let noExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        let task = Task {
            try? await sut.load()
        }
        await Task.yield()
        store.completeRetrieval(with: feed.local, timestamp: noExpiredTimestamp)
        _ = await task.result
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnCacheExpiration() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        let task = Task {
            try? await sut.load()
        }
        await Task.yield()
        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)
        _ = await task.result
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnExpiredCache() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        let task = Task {
            try? await sut.load()
        }
        await Task.yield()
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        _ = await task.result
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: Result<[FeedImage], Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) async {
        let task = Task { () -> Result<[FeedImage], Error> in
            do {
                return .success(try await sut.load())
            } catch {
                return .failure(error)
            }
        }

        await Task.yield()
        action()
        let receivedResult = await task.value

        switch (receivedResult, expectedResult) {
        case let (.success(receivedImages), .success(expectedImages)):
            XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)

        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)

        default:
            XCTFail("Expected result \(expectedResult), got \(receivedResult) instead")
        }
    }
}
