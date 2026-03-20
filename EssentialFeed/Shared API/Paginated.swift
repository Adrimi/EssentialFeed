//
//  Created by Adrian Szymanowski on 20/04/2021.
//

import Foundation

public struct Paginated<Item> {
    public let items: [Item]
    public let loadMore: (() async throws -> Self)?
    
    public init(items: [Item], loadMore: (() async throws -> Self)? = nil) {
        self.items = items
        self.loadMore = loadMore
    }
}
