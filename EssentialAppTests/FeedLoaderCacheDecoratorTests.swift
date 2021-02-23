//
// Copyright © 2021 Adrian Szymanowski. All rights reserved.
//

import XCTest
import EssentialFeed

protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}

final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map { feed in
                self?.cache.save(feed) { _ in }
                return feed
            })
        }
    }
}

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {

    func test_load_deliversFeedOnLoaderSuccess() {
        let expectedResult = FeedLoader.Result.success(uniqueFeed())
        let (sut, _) = makeSUT(with: expectedResult)
        
        expect(sut, toCompleteWith: expectedResult)
    }
    
    func test_load_deliversErrorOnLoaderFailures() {
        let expectedResult = FeedLoader.Result.failure(anyNSError())
        let (sut, _) = makeSUT(with: expectedResult)
        
        expect(sut, toCompleteWith: expectedResult)
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let (sut, cache) = makeSUT(with: .success(feed))
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
    }
    
    func test_load_doesNotCacheOnLoadFailure() {
        let (sut, cache) = makeSUT(with: .failure(anyNSError()))
        
        sut.load { _ in }
        
        XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache feed on load error")
    }
    
    // MARK: - Helpers

    private func makeSUT(with expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> (sut: FeedLoaderCacheDecorator, cache: CacheSpy) {
        let loader = FeedLoaderStub(result: expectedResult)
        let cache = CacheSpy()
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, cache)
    }
    
    private class CacheSpy: FeedCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
}
