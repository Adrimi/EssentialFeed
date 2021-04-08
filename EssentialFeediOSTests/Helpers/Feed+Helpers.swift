//
//  Feed+Helpers.swift
//  EssentialFeediOSTests
//
//  Created by Adrian Szymanowski on 08/04/2021.
//

import UIKit
import EssentialFeediOS

func emptyFeed() -> [FeedImageCellController] { [] }

func feedWithContent() -> [ImageStub] {
    [
        ImageStub(
            description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
            location: "East Side Gallery\nMemorial in Berlin, Germany",
            image: UIImage.make(withColor: .red)
        ),
        ImageStub(
            description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
            location: "Garth Pier",
            image: UIImage.make(withColor: .green)
        )
    ]
}

func feedWithFailedImageLoading() -> [ImageStub] {
    [
        ImageStub(
            description: nil,
            location: "Cannon Street, London",
            image: nil
        ),
        ImageStub(
            description: nil,
            location: "Brighton Seafront",
            image: nil
        )
    ]
}
