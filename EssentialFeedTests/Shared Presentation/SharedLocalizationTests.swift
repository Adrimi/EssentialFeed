//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Adrian Szymanowski on 06/04/2021.
//

import EssentialFeed
import XCTest

class SharedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        
        assertLocalizedKeysAndValuesExists(in: bundle, table)
    }
    
    // MARK: - Helpers
    
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
}
