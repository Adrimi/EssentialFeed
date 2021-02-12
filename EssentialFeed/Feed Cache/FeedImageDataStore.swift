//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 12/02/2021.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
