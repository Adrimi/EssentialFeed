//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 05/02/2021.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        location != nil
    }
}
