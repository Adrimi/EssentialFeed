//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by adrian.szymanowski on 11/10/2020.
//

import Foundation

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedItem] {
            items.map(\.feedItem)
        }
    }

    // API representation of model. Thus "FeedItem" does not have information of the API implementation and it separate concern of difference in API model and in-app model!
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static private var ACK_200: Int { 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == ACK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feed)
    }
}
