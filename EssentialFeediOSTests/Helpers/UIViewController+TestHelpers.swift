//
//  UIViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Adrian Szymanowski on 08/04/2021.
//

import UIKit

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}
