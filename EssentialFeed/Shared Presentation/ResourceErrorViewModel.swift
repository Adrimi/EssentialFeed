//
//  Created by Adrian Szymanowski on 03/02/2021.
//

import Foundation

public struct ResourceErrorViewModel {
    public let message: String?
    
    public static var noError: ResourceErrorViewModel {
        ResourceErrorViewModel(message: .none)
    }
    
    public static func error(message: String) -> ResourceErrorViewModel {
        ResourceErrorViewModel(message: message)
    }
}
