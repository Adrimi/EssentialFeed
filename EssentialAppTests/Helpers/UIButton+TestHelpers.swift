//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Adrian Szymanowski on 02/02/2021.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
