//
//  Created by Adrian Szymanowski on 08/01/2021.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
