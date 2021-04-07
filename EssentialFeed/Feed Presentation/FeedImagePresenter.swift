//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 05/02/2021.
//

import Foundation

final public  class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location
        )
    }
}

