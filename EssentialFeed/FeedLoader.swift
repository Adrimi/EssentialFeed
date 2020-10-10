//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by adrian.szymanowski on 10/10/2020.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
