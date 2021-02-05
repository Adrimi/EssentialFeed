//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 03/02/2021.
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?
    
    public static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: .none)
    }
    
    public static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
