//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Adrian Szymanowski on 16/01/2021.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        
        assertLocalizedKeysAndValuesExists(in: bundle, table)
    }
    
}
