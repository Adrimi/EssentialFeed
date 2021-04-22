//
//  FeedImageDataCache.swift
//  EssentialApp
//
//  Created by Adrian Szymanowski on 23/02/2021.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
