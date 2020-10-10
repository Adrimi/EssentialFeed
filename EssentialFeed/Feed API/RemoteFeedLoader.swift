//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by adrian.szymanowski on 10/10/2020.
//

import Foundation

public typealias HTTPClientResponse = (Error?, HTTPURLResponse?) -> Void

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping HTTPClientResponse)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { error, response in
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
            }
        }
    }
}
