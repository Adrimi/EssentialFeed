//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 28/03/2021.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
    }
}
