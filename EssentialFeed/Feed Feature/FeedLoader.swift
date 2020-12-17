//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by adrian.szymanowski on 10/10/2020.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
