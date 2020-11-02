//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by adrian.szymanowski on 02/11/2020.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
