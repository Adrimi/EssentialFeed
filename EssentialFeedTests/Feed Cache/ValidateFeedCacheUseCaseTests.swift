//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by adrian.szymanowski on 06/11/2020.
//  
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() async {
        let (sut, store) = makeSUT()
        
        let task = Task {
            try? await sut.validateCache()
        }
        await Task.yield()
        store.completeRetrieval(with: anyNSError())
        await Task.yield()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
        store.completeDeletionSuccessfully()
        _ = await task.result
    }
    
    func test_validateCache_doesNotDeletesCacheOnEmptyCache() async {
        let (sut, store) = makeSUT()
        
        let task = Task {
            try? await sut.validateCache()
        }
        await Task.yield()
        store.completeRetrievalWithEmptyCache()
        _ = await task.result
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteNonExpiredCache() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let noExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        let task = Task {
            try? await sut.validateCache()
        }
        await Task.yield()
        store.completeRetrieval(with: feed.local, timestamp: noExpiredTimestamp)
        _ = await task.result
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnExpiration() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        let task = Task {
            try? await sut.validateCache()
        }
        await Task.yield()
        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)
        await Task.yield()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
        store.completeDeletionSuccessfully()
        _ = await task.result
    }
    
    func test_validateCache_deletesExpiredCache() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        let task = Task {
            try? await sut.validateCache()
        }
        await Task.yield()
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        await Task.yield()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
        store.completeDeletionSuccessfully()
        _ = await task.result
    }
    
    func test_validateCache_succeedsOnNonExpiredCache() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        await expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        })
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() async {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        await expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_validateCache_failsOnDeleteionErrorOfExpiredCache() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let deletionError = anyNSError()
        
        await expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() async {
         let feed = uniqueImageFeed()
         let fixedCurrentDate = Date()
         let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
         let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

         await expect(sut, toCompleteWith: .success(()), when: {
             store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
             store.completeDeletionSuccessfully()
         })
     }
    
    func test_validateCache_failsOnDeletionErrorOfExpiredCache() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let deletionError = anyNSError()
        
        await expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() async {
         let (sut, store) = makeSUT()

         await expect(sut, toCompleteWith: .success(()), when: {
             store.completeRetrieval(with: anyNSError())
             store.completeDeletionSuccessfully()
         })
     }
    
    func test_validateCache_succeedsOnEmptyCache() async {
        let (sut, store) = makeSUT()
        
        await expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: Result<Void, Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) async {
        let task = Task { () -> Result<Void, Error> in
            do {
                try await sut.validateCache()
                return .success(())
            } catch {
                return .failure(error)
            }
        }

        await Task.yield()
        action()
        let receivedResult = await task.value

        switch (receivedResult, expectedResult) {
        case (.success, .success):
            break

        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)

        default:
            XCTFail("Expected result \(expectedResult), got\(receivedResult) instead", file: file, line: line)
        }
    }
}
