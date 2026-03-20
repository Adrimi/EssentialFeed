//
// Copyright © 2021 Adrian Szymanowski. All rights reserved.
//

import XCTest
import EssentialFeed

class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() async {
        let sut = makeSUT()
        
        await expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() async {
        let sut = makeSUT()
        let url = URL(string: "http://a-url.com/")!
        let nonMatchingURL = URL(string: "http://another-url.com/")!
        
        await insert(anyData(), for: url, into: sut)
        
        await expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
    }
    
    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() async {
        let sut = makeSUT()
        let storedData = anyData()
        let matchingURL = URL(string: "http://a-url.com")!
        
        await insert(storedData, for: matchingURL, into: sut)
        
        await expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingURL)
    }
    
    func test_retrieveImageData_deliversLastInsertedValue() async {
        let sut = makeSUT()
        let firstStoredData = Data("first".utf8)
        let lastStoredData = Data("last".utf8)
        let url = URL(string: "http://a-url.com/")!
        
        await insert(firstStoredData, for: url, into: sut)
        await insert(lastStoredData, for: url, into: sut)
        
        await expect(sut, toCompleteRetrievalWith: found(lastStoredData), for: url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func notFound() -> Result<Data?, Error> {
        .success(.none)
    }
    
    private func found(_ data: Data) -> Result<Data?, Error> {
        .success(data)
    }
    
    private func localImage(url: URL) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: Result<Data?, Error>, for url: URL, file: StaticString = #filePath, line: UInt = #line) async {
        let receivedResult: Result<Data?, Error>

        do {
            receivedResult = .success(try await sut.retrieve(dataForURL: url))
        } catch {
            receivedResult = .failure(error)
        }
        
        switch (receivedResult, expectedResult) {
        case let (.success(receivedData), .success(expectedData)):
            XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            
        default:
            XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #filePath, line: UInt = #line) async {
        let image = localImage(url: url)

        do {
            try await sut.insert([image], timestamp: Date())
            try await sut.insert(data, for: url)
        } catch {
            XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
        }
    }
    
}
