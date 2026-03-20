//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by adrian.szymanowski on 23/11/2020.
//

import XCTest
import EssentialFeed

private actor CompletionOrder {
    private var values = [Int]()

    func append(_ value: Int) {
        values.append(value)
    }

    func snapshot() -> [Int] {
        values
    }
}

extension FeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) async {
        await expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) async {
        await expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) async {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        await insert((feed, timestamp), to: sut)
        await expect(sut, toRetrieve: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) async {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        await insert((feed, timestamp), to: sut)
        await expect(sut, toRetrieveTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) async {
        let insertionError = await insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) async {
        await insert((uniqueImageFeed().local, Date()), to: sut)
        
        let insertionError = await insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) async {
        await insert((uniqueImageFeed().local, Date()), to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        await insert((latestFeed, latestTimestamp), to: sut)
        
        await expect(sut, toRetrieve: .success(CachedFeed(feed: latestFeed, timestamp: latestTimestamp)), file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) async {
        await deleteCache(from: sut)
        
        await expect(sut, toRetrieve: .success(.none))
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) async {
        await insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = await deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) async {
        await insert((uniqueImageFeed().local, Date()), to: sut)
        
        await deleteCache(from: sut)
        
        await expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) async {
        let completedOperationsInOrder = CompletionOrder()

        let op1 = expectation(description: "Operation 1")
        Task {
            try? await sut.insert(uniqueImageFeed().local, timestamp: Date())
            await completedOperationsInOrder.append(1)
            op1.fulfill()
        }
        await Task.yield()
        
        let op2 = expectation(description: "Operation 2")
        Task {
            try? await sut.insert(uniqueImageFeed().local, timestamp: Date())
            await completedOperationsInOrder.append(2)
            op2.fulfill()
        }
        await Task.yield()
        
        let op3 = expectation(description: "Operation 3")
        Task {
            try? await sut.insert(uniqueImageFeed().local, timestamp: Date())
            await completedOperationsInOrder.append(3)
            op3.fulfill()
        }
        
        await fulfillment(of: [op1, op2, op3], timeout: 1.0)

        let completionOrder = await completedOperationsInOrder.snapshot()
        XCTAssertEqual(completionOrder, [1, 2, 3], "Expected side-effects to run serially, but operations finished in wrong order", file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: Result<CachedFeed?, Error>, file: StaticString = #filePath, line: UInt = #line) async {
        await expect(sut, toRetrieve: expectedResult)
        await expect(sut, toRetrieve: expectedResult)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: Result<CachedFeed?, Error>, file: StaticString = #filePath, line: UInt = #line) async {
        let retrievedResult: Result<CachedFeed?, Error>

        do {
            retrievedResult = .success(try await sut.retrieve())
        } catch {
            retrievedResult = .failure(error)
        }

        switch (expectedResult, retrievedResult) {
        case (.success(.none), .success(.none)),
             (.failure, .failure):
            break

        case let (.success(.some(expectedCache)), .success(.some(retrievedCache))):
            XCTAssertEqual(retrievedCache.feed, expectedCache.feed, file: file, line: line)
            XCTAssertEqual(retrievedCache.timestamp, expectedCache.timestamp, file: file, line: line)

        default:
            XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
        }
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) async -> Error? {
        do {
            try await sut.insert(cache.feed, timestamp: cache.timestamp)
            return nil
        } catch {
            return error
        }
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) async -> Error? {
        do {
            try await sut.deleteCachedFeed()
            return nil
        } catch {
            return error
        }
    }
    
}
