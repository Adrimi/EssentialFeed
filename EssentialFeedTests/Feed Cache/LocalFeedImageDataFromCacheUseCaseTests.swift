//
// Copyright © 2021 Adrian Szymanowski. All rights reserved.
//

import XCTest
import EssentialFeed

class LocalFeedImageDataFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataFromURL() async {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        let task = Task {
            try? await sut.loadImageData(from: url)
        }
        await Task.yield()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
        store.completeRetrieval(with: .none)
        _ = await task.result
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() async {
        let (sut, store) = makeSUT()
        
        await expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyNSError()
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() async {
        let (sut, store) = makeSUT()
        
        await expect(sut, toCompleteWith: notFound(), when: {
            store.completeRetrieval(with: .none)
        })
    }
    
    func test_loadImageDataFromURL_deliversStoreDataOnFoundData() async {
        let (sut, store) = makeSUT()
        let foundData = anyData()
        
        await expect(sut, toCompleteWith: .success(foundData), when: {
            store.completeRetrieval(with: foundData)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func failed() -> Result<Data, Error> {
        .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> Result<Data, Error> {
        .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func never(file: StaticString = #filePath, line: UInt = #line) {
        XCTFail("Expected no invocations", file: file, line: line)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: Result<Data, Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) async {
        let task = Task { () -> Result<Data, Error> in
            do {
                return .success(try await sut.loadImageData(from: anyURL()))
            } catch {
                return .failure(error)
            }
        }

        await Task.yield()
        action()
        
        let receivedResult = await task.value
        
        switch (receivedResult, expectedResult) {
        case let (.success(receivedData), .success(expectedData)):
            XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            
        case (.failure(let receivedError as LocalFeedImageDataLoader.LoadError), .failure(let expectedError as LocalFeedImageDataLoader.LoadError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
        default:
            XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
}
