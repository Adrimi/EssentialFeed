//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Adrian Szymanowski on 11/02/2021.
//

import Foundation
import EssentialFeed

class HTTPClientSpy: HTTPClient {
    private final class Request {
        let url: URL
        private let lock = NSLock()
        private var continuation: CheckedContinuation<(Data, HTTPURLResponse), Error>?

        init(url: URL) {
            self.url = url
        }

        func store(_ continuation: CheckedContinuation<(Data, HTTPURLResponse), Error>) {
            lock.lock()
            self.continuation = continuation
            lock.unlock()
        }

        func resume(with result: Result<(Data, HTTPURLResponse), Error>) {
            lock.lock()
            let continuation = self.continuation
            self.continuation = nil
            lock.unlock()

            guard let continuation else { return }

            switch result {
            case let .success(value):
                continuation.resume(returning: value)
            case let .failure(error):
                continuation.resume(throwing: error)
            }
        }
    }
    
    private var messages = [Request]()
    private(set) var cancelledURLs = [URL]()
    
    var requestedURLs: [URL] {
        messages.map(\.url)
    }
    
    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let request = Request(url: url)
        messages.append(request)

        return try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                request.store(continuation)
            }
        }, onCancel: { [weak self] in
            self?.cancelledURLs.append(url)
            request.resume(with: .failure(CancellationError()))
        })
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].resume(with: .failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil)!
        messages[index].resume(with: .success((data, response)))
    }
}
