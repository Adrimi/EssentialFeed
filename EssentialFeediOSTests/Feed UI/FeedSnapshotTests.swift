//
//  Created by Adrian Szymanowski on 24/02/2021.
//

import XCTest
@testable import EssentialFeed
import EssentialFeediOS

class FeedSnapshotTests: XCTestCase {
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "FEED_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_light_extraExtraExtraLarge")
    }
    
    func test_feedWithLoadMoreIndicator() {
        let sut = makeSUT()
        
        sut.display(feedWithLoadMoreIndicator())
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "FEED_WITH_LOAD_MORE_INDICATOR_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "FEED_WITH_LOAD_MORE_INDICATOR_dark")
    }
    
    func test_feedWithLoadMoreError() {
        let sut = makeSUT()
        
        sut.display(feedWithLoadMoreError())
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "FEED_WITH_LOAD_MORE_ERROR_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "FEED_WITH_LOAD_MORE_ERROR_dark")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_LOAD_MORE_ERROR_light_extraExtraExtraLarge")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func feedWithLoadMoreIndicator() -> [CellController] {
        let loadMore = LoadMoreCellController(callback: {})
        loadMore.display(ResourceLoadingViewModel(isLoading: true))
        return feedWith(loadMore: loadMore)
    }
    
    private func feedWithLoadMoreError() -> [CellController] {
        let loadMore = LoadMoreCellController(callback: {})
        loadMore.display(ResourceErrorViewModel(message: "Multiline\nerror message"))
        return feedWith(loadMore: loadMore)
    }
    
    private func feedWith(loadMore: LoadMoreCellController) -> [CellController] {
        let stub = feedWithContent().last!
        let cellController = FeedImageCellController(
            viewModel: stub.viewModel,
            delegate: stub,
            selection: {})
        stub.controller = cellController
        
        return [
            CellController(id: UUID(), cellController),
            CellController(id: UUID(), loadMore)
        ]
    }
    
}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [CellController] = stubs.map { stub in
            let cellController = FeedImageCellController(
                viewModel: stub.viewModel,
                delegate: stub,
                selection: {})
            stub.controller = cellController
            return CellController(id: UUID(), cellController)
        }
        
        display(cells)
    }
}
