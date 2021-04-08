//
//  Created by Adrian Szymanowski on 08/04/2021.
//

import UIKit

public protocol CellController {
    func view(in: UITableView) -> UITableViewCell
    func preload()
    func cancelLoad()
}
