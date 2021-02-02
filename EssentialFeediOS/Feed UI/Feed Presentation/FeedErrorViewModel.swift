//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 02/02/2021.
//

import Foundation

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: .none)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
