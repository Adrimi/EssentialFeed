//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by adrian.szymanowski on 10/10/2020.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
