//
//  FeedUIIntegrationTests.swift
//  EssentialFeed
//
//  Created by adrian.szymanowski on 04/01/2021.
//  
//

import XCTest
import EssentialFeed
import EssentialFeediOS
import EssentialApp

@MainActor
final class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() async {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        
        XCTAssertEqual(sut.title, feedTitle)
    }
    
    func test_imageSelection_notifiesHandler() async {
        let image0 = makeImage()
        let image1 = makeImage()
        var selectedImages = [FeedImage]()
        let (sut, loader) = makeSUT(selection: { selectedImages.append($0) })
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        await waitForUIToUpdate()
        
        sut.simulateTapOnFeedImage(at: 0)
        XCTAssertEqual(selectedImages, [image0])
        
        sut.simulateTapOnFeedImage(at: 1)
        XCTAssertEqual(selectedImages, [image0, image1])
    }
    
    func test_loadFeedActions_requestFeedFromLoader() async {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is lodaded")
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected no request until previous completes")
        
        loader.completeFeedLoading(at: 0)
        await waitForUIToUpdate()
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a reload")
        
        loader.completeFeedLoading(at: 1)
        await waitForUIToUpdate()
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadMoreActions_requestMoreFromLoader() async {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading()
        await waitForUIToUpdate()
        
        XCTAssertEqual(loader.loadMoreCallCount, 0, "Expected no requests until load more action")
        
        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected load more request")
        
        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected no request while it is loading more already")
        
        loader.completeLoadMore(lastPage: false, at: 0)
        await waitForUIToUpdate()
        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadMoreCallCount, 2, "Expected request after load more completed with more pages")
        
        loader.completeLoadMoreWithError(at: 1)
        await waitForUIToUpdate()
        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected request after load more failure")
        
        loader.completeLoadMore(lastPage: true, at: 2)
        await waitForUIToUpdate()
        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected no request after loading all pages")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() async {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        await waitForUIToUpdate()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeFeedLoadingWithError(at: 1)
        await waitForUIToUpdate()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completed with an error")
    }
    
    func test_loadingMoreIndicator_isVisibleWhileLoadingMore() async {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        await waitForUIToUpdate()
        XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once view completes successfully")

        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        XCTAssertTrue(sut.isShowingLoadMoreFeedIndicator, "Expected loading indicator on load more action")

        loader.completeLoadMore(at: 0)
        await waitForUIToUpdate()
        XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        XCTAssertTrue(sut.isShowingLoadMoreFeedIndicator, "Expected loading indicator on second load more action")
        
        loader.completeLoadMoreWithError(at: 1)
        await waitForUIToUpdate()
        XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once loading completes with error")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() async {
        let image0 = makeImage(description: "A description", location: "A location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [image0, image1])
        
        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        loader.completeLoadMore(with: [image0, image1, image2, image3], at: 0)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [image0, image1, image2, image3])
        
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [image0, image1], at: 1)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [image0, image1])
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() async {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [image0], at: 0)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [image0])
        
        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        loader.completeLoadMore(with: [image0, image1], at: 0)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [image0, image1])
        
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [], at: 1)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() async {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [image0], at: 0)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        loader.completeFeedLoadingWithError(at: 1)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [image0])
        
        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        loader.completeLoadMoreWithError(at: 0)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [image0])
    }
    
    func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() async {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeFeedLoadingWithError(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_tapOnError_hidesErrorMessage() async {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeFeedLoadingWithError(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_loadMoreCompletion_rendersErrorMessageOnError() async {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading()
        await waitForUIToUpdate()
        
        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        XCTAssertNil(sut.loadMoreFeedErrorMessage)
        
        loader.completeLoadMoreWithError(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(sut.loadMoreFeedErrorMessage, loadError)
        
        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        XCTAssertNil(sut.loadMoreFeedErrorMessage)
    }
    
    func test_tapOnLoadMoreFeedErrorView_loadsMore() async {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading()
        await waitForUIToUpdate()

        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadMoreCallCount, 1)
        
        sut.simulateTapOnLoadMoreFeedError()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadMoreCallCount, 1)
        
        loader.completeLoadMoreWithError(at: 0)
        await waitForUIToUpdate()
        sut.simulateTapOnLoadMoreFeedError()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadMoreCallCount, 2)
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() async {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [image0, image1])
        await waitForUIToUpdate()
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once first view becomes visible")
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() async {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [image0, image1])
        await waitForUIToUpdate()
        
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URL request once first image is not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible")
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() async {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        await waitForUIToUpdate()
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        await waitForUIToUpdate()
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        await waitForUIToUpdate()
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() async {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        await waitForUIToUpdate()

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        await waitForUIToUpdate()
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")

        loader.completeImageLoading(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")

        loader.completeImageLoadingWithError(at: 1)
        await waitForUIToUpdate()
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }

    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() async {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        await waitForUIToUpdate()
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        await waitForUIToUpdate()
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        await waitForUIToUpdate()
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() async {
     let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [makeImage()])
        await waitForUIToUpdate()
        
        let view = sut.simulateFeedImageViewVisible(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("Invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() async {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [image0, image1])
        await waitForUIToUpdate()
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two image URL requests for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expected third imageURL request after first veiw retry action")
        
        view1?.simulateRetryAction()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expected fourth imageURL request after second veiw retry action")
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() async {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [image0, image1])
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 1)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second image is near visible")
    }
    
    func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() async {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [image0, image1])
        await waitForUIToUpdate()
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requetst until image is not near visible")
        
        sut.simulateFeedImageViewNotNearVisible(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateFeedImageViewNotNearVisible(at: 1)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second cancelled image URL request once second image is not near visible anymore ")
    }
    
    func test_feedImageView_doesNotLoadImageAgainUntilPreviousCompletes() async {
        let image = makeImage(url: URL(string: "http://url-0.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [image])
        await waitForUIToUpdate()
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadedImageURLs, [image.url], "Expected first request when near visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadedImageURLs, [image.url], "Expected no request until previous completes")
        
        loader.completeImageLoading(at: 0)
        await waitForUIToUpdate()
        sut.simulateFeedImageViewVisible(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadedImageURLs, [image.url, image.url], "Expected second request when visible after previous complete")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        await waitForUIToUpdate()
        sut.simulateFeedImageViewVisible(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadedImageURLs, [image.url, image.url, image.url], "Expected third request when visible after cancelling previous complete")
        
        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        loader.completeLoadMore(with: [image, makeImage()], at: 0)
        await waitForUIToUpdate()
        sut.simulateFeedImageViewVisible(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadedImageURLs, [image.url, image.url, image.url], "Expected no request until previous completes")
    }
    
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() async {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [makeImage()])
        await waitForUIToUpdate()
        
        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        await waitForUIToUpdate()
        loader.completeImageLoading(with: anyImageData())
        await waitForUIToUpdate()
        
        XCTAssertNil(view?.renderedImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() async {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        
        await completeOnBackgroundThread {
            loader.completeFeedLoading(at: 0)
        }
        await waitForUIToUpdate()
    }
    
    func test_loadMoreCompletion_dispatchesFromBackgroundToMainThread() async {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(at: 0)
        await waitForUIToUpdate()
        sut.simulateLoadMoreFeedAction()
        await waitForUIToUpdate()
        
        await completeOnBackgroundThread {
            loader.completeLoadMore()
        }
        await waitForUIToUpdate()
    }
    
    func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() async {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeFeedLoading(with: [makeImage()])
        await waitForUIToUpdate()
        _ = sut.simulateFeedImageViewVisible(at: 0)
        await waitForUIToUpdate()
        
        let imageData = anyImageData()
        await completeOnBackgroundThread {
            loader.completeImageLoading(with: imageData, at: 0)
        }
        await waitForUIToUpdate()
    }
    
    // MARK: - Helper Methods
    
    private func makeSUT(
        selection: @escaping (FeedImage) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ListViewController, laoder: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(
            feedLoader: loader.load,
            imageLoader: loader.loadImageData,
            selection: selection)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    private func waitForUIToUpdate() async {
        for _ in 0..<5 {
            await Task.yield()
        }
    }

    private func completeOnBackgroundThread(_ action: @escaping @Sendable () -> Void) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                action()
                continuation.resume()
            }
        }
    }
    
    private func assertThat(_ sut: ListViewController, isRendering feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            self.assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: ListViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShoiwngLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index))", file: file, line: line)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func anyImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }
    
}
