//
//  Created by Adrian Szymanowski on 23/02/2021.
//  Based on gh123man on 04/08/2017 form https://stackoverflow.com/a/45515130
//

import XCTest

class OptimizedTestCase: XCTestCase {
    static var swizzledOutIdle = false

    override func setUp() {
        if !OptimizedTestCase.swizzledOutIdle { // ensure the swizzle only happens once
            let original = class_getInstanceMethod((objc_getClass("XCUIApplicationProcess") as! AnyClass), Selector(("waitForQuiescenceIncludingAnimationsIdle:")))!
            let replaced = class_getInstanceMethod(type(of: self), #selector(OptimizedTestCase.replace))!
            method_exchangeImplementations(original, replaced)
            OptimizedTestCase.swizzledOutIdle = true
        }
        super.setUp()
    }

    @objc func replace() {
        return
    }
}
