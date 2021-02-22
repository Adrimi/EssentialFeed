//
// Copyright © 2021 Adrian Szymanowski. All rights reserved.
//

import XCTest
import EssentialFeed

final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}

class FeedLoaderCacheDecoratorTests: XCTestCase {

    func test_load_deliversFeedOnLoaderSuccess() {
        let expectedResult = FeedLoader.Result.success(uniqueFeed())
        let sut = makeSUT(with: expectedResult)
        
        expect(sut, toCompleteWith: expectedResult)
    }
    
    func test_load_deliversErrorOnLoaderFailures() {
        let expectedResult = FeedLoader.Result.failure(anyNSError())
        let sut = makeSUT(with: expectedResult)
        
        expect(sut, toCompleteWith: expectedResult)
    }
    
    // MARK: - Helpers

    private func makeSUT(with expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoaderCacheDecorator {
        let loader = FeedLoaderStub(result: expectedResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        return sut
    }
}
