//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 11/02/2021.
//

import Foundation

public class RemoteFeedImageDataLoader: FeedImageDataLoader {
    public typealias Result = (FeedImageDataLoader.Result) -> Void
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherComlpetions()
            wrapped?.cancel()
        }
        
        private func preventFurtherComlpetions() {
            completion = nil
        }
    }
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping Result) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
            case let .failure(error): task.complete(with: .failure(error))
            }
        }
        
        return task
    }
}

