//
//  Created by Adrian Szymanowski on 07/04/2021.
//

import XCTest
import EssentialFeed

class ImageCommentsLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        
        assertLocalizedKeysAndValuesExists(in: bundle, table)
    }
}

