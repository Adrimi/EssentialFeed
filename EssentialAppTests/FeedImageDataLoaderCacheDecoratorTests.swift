//
// Copyright © 2021 Adrian Szymanowski. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderCacheDecorator {
    init(loader: Any) {
        
    }
}

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {

    func test_init_doesNotLoadImageData() {
        let (_, loader) = makeSUT()
        
        XCTAssertTrue(loader.loadedURLs.isEmpty)
    }
    
    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderCacheDecorator, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(loader: loader)
        return (sut, loader)
    }
    
    private class LoaderSpy {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedURLs: [URL] {
            messages.map(\.url)
        }
    }

}
