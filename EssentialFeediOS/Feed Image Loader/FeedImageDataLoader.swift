//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 08/01/2021.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
