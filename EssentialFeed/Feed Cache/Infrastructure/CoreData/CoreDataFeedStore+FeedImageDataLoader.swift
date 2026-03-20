//
//  Created by Adrian Szymanowski on 15/02/2021.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(_ data: Data, for url: URL) async throws {
        try await perform { context in
            try ManagedFeedImage.first(with: url, in: context)
                .map { $0.data = data }
                .map(context.save)
        }
    }

    public func retrieve(dataForURL url: URL) async throws -> Data? {
        try await perform { context in
            try ManagedFeedImage.data(with: url, in: context)
        }
    }
}
