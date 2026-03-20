//
//  FeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by adrian.szymanowski on 28/10/2020.
//

import XCTest
import EssentialFeed

class FeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() async {
        let (sut, store) = makeSUT()
        
        let task = Task {
            try? await sut.save(uniqueImageFeed().models)
        }
        await waitForStoreOperation()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
        store.completeDeletion(with: anyNSError())
        _ = await task.result
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() async {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        let task = Task {
            try? await sut.save(uniqueImageFeed().models)
        }
        await waitForStoreOperation()
        store.completeDeletion(with: deletionError)
        _ = await task.result
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesRequestCacheInsertion_withTimestamp_OnDeletionSuccess() async {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let feed = uniqueImageFeed()
        
        let task = Task {
            try? await sut.save(feed.models)
        }
        await waitForStoreOperation()
        store.completeDeletionSuccessfully()
        await waitForStoreOperation()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timestamp)])
        store.completeInsertionSuccessfully()
        _ = await task.result
    }
    
    func test_save_failsOnDeletionError() async {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        await expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_save_failsOnInsertionError() async {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        await expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_succedsOnSuccessfulCacheInsertion() async {
        let (sut, store) = makeSUT()
        
        await expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
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
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) async {
        let task = Task { () -> Error? in
            do {
                try await sut.save(uniqueImageFeed().models)
                return nil
            } catch {
                return error
            }
        }

        await waitForStoreOperation()
        action()
        let receivedError = await task.value
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }

    private func waitForStoreOperation() async {
        for _ in 0..<5 {
            await Task.yield()
        }
    }
    
}
