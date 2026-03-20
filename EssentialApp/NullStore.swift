//
//  Created by Adrian Szymanowski on 21/04/2021.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    func deleteCachedFeed() async throws {}
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) async throws {}
    
    func retrieve() async throws -> CachedFeed? { .none }
    
    func insert(_ data: Data, for url: URL) async throws {}

    func retrieve(dataForURL url: URL) async throws -> Data? { .none }
}
