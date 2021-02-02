//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 02/02/2021.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
