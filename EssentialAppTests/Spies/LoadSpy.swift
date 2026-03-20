//
//  LoadSpy.swift
//  EssentialFeediOSTests
//
//  Created by Adrian Szymanowski on 02/02/2021.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class AsyncResultRequest<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Value, Error>?

    func value(onCancel: (() -> Void)? = nil) async throws -> Value {
        try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                store(continuation)
            }
        }, onCancel: { [weak self] in
            onCancel?()
            self?.resume(throwing: CancellationError())
        })
    }

    func resume(returning value: Value) {
        resume(with: .success(value))
    }

    func resume(throwing error: Error) {
        resume(with: .failure(error))
    }

    private func store(_ continuation: CheckedContinuation<Value, Error>) {
        lock.lock()
        self.continuation = continuation
        lock.unlock()
    }

    private func resume(with result: Result<Value, Error>) {
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

extension FeedUIIntegrationTests {
    
    // MARK: - LoaderSpy
    final class LoaderSpy: @unchecked Sendable {
        
        // MARK: - FeedLoader
        
        private var feedRequests = [AsyncResultRequest<Paginated<FeedImage>>]()
        private var loadMoreRequests = [AsyncResultRequest<Paginated<FeedImage>>]()
        
        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        var loadMoreCallCount: Int {
            loadMoreRequests.count
        }
        
        func load() async throws -> Paginated<FeedImage> {
            let request = AsyncResultRequest<Paginated<FeedImage>>()
            feedRequests.append(request)
            return try await request.value()
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index].resume(
                returning: Paginated(
                    items: feed,
                    loadMore: { [self] in
                        try await loadMore()
                    }))
        }
        
        func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int = 0) {
            loadMoreRequests[index].resume(
                returning:
                Paginated(
                    items: feed,
                    loadMore: lastPage ? nil : { [self] in
                        try await loadMore()
                    }
                )
            )
        }
        
        func completeLoadMoreWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            loadMoreRequests[index].resume(throwing: error)
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index].resume(throwing: error)
        }
        
        // MARK: - FeedImageDataLoader
        
        private var imageRequests = [(url: URL, request: AsyncResultRequest<Data>)]()
        
        var loadedImageURLs: [URL] {
            imageRequests.map(\.url)
        }
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL) async throws -> Data {
            let request = AsyncResultRequest<Data>()
            imageRequests.append((url, request))
            return try await request.value(onCancel: { [weak self] in
                self?.cancelledImageURLs.append(url)
            })
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].request.resume(returning: imageData)
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            imageRequests[index].request.resume(throwing: anyNSError())
        }

        private func loadMore() async throws -> Paginated<FeedImage> {
            let request = AsyncResultRequest<Paginated<FeedImage>>()
            loadMoreRequests.append(request)
            return try await request.value()
        }
        
    }
    
}
