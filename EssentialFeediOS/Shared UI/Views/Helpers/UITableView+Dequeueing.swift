//
//  UITableView+dequeueing.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 16/01/2021.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
