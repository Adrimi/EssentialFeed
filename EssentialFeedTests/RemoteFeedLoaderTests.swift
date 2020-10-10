//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by adrian.szymanowski on 10/10/2020.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesnotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }

}
