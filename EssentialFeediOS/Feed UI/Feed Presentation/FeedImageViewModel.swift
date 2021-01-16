//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 09/01/2021.
//

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}

