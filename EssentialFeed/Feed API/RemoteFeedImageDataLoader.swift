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
        case connectivity
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

            task.complete(
                with: result
                    .mapError { _ in Error.connectivity }
                    .flatMap { (data, response) in
                        let isValidResponse = response.statusCode == 200 && !data.isEmpty
                        return isValidResponse ? .success(data) : .failure(Error.invalidData)
                    }
            )
        }
        
        return task
    }
}

