//
// Copyright © 2021 Adrian Szymanowski. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
import EssentialApp

@MainActor
final class CommentsUIIntegrationTests: XCTestCase {

    func test_commentsView_hasTitle() async {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadCommentsActions_requestCommentsFromLoader() async {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is lodaded")
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected no request until previous completes")
        
        loader.completeCommentsLoading(at: 0)
        await waitForUIToUpdate()
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a reload")
        
        loader.completeCommentsLoading(at: 1)
        await waitForUIToUpdate()
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() async {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeCommentsLoading(at: 0)
        await waitForUIToUpdate()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeCommentsLoadingWithError(at: 1)
        await waitForUIToUpdate()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completed with an error")
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() async {
        let comment0 = makeComment(message: "a message", username: "a location")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [])
        
        loader.completeCommentsLoading(with: [comment0], at: 0)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [comment0, comment1])
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() async {
        let comment = makeComment()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [])
        
        loader.completeCommentsLoading(with: [comment], at: 0)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [comment])
        
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        loader.completeCommentsLoading(with: [], at: 1)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [])
    }
    
    func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() async {
        let comment = makeComment()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        loader.completeCommentsLoading(with: [comment], at: 0)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [comment])
        
        sut.simulateUserInitiatedReload()
        await waitForUIToUpdate()
        loader.completeCommentsLoadingWithError(at: 1)
        await waitForUIToUpdate()
        assertThat(sut, isRendering: [comment])
    }
    
    func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() async {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
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
        
        loader.completeCommentsLoadingWithError(at: 0)
        await waitForUIToUpdate()
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertNil(sut.errorMessage)
    }
    
    
    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() async {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        await waitForUIToUpdate()
        
        await completeOnBackgroundThread {
            loader.completeCommentsLoading(at: 0)
        }
        await waitForUIToUpdate()
    }
    
    func test_deinit_cancelsRunningRequest() async {
        var cancelCount = 0
        var sut: ListViewController?
        let request = AsyncResultRequest<[ImageComment]>()
        
        autoreleasepool {
            sut = CommentsUIComposer.commentsComposedWith {
                try await request.value(onCancel: {
                    cancelCount += 1
                })
            }
            sut?.loadViewIfNeeded()
        }
        await waitForUIToUpdate()
        
        XCTAssertEqual(cancelCount, 0)
        
        sut = nil
        await waitForUIToUpdate()
        
        XCTAssertEqual(cancelCount, 1)
    }
    
    // MARK: - Helper Methods
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, laoder: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.load)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedComments(), comments.count, "comments count", file: file, line: line)
        
        let viewModel = ImageCommentsPresenter.map(comments)
        
        viewModel.comments.enumerated().forEach { index, comment in
            XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentDate(at: index), comment.date, "date at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentUsername(at: index), comment.username, "username at \(index)", file: file, line: line)
        }
    }
    
    private func makeComment(message: String = "any message", username: String = "any username") -> ImageComment {
        ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
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
    
    private final class LoaderSpy: @unchecked Sendable {
        private var requests = [AsyncResultRequest<[ImageComment]>]()
        
        var loadCommentsCallCount: Int {
            requests.count
        }
        
        func load() async throws -> [ImageComment] {
            let request = AsyncResultRequest<[ImageComment]>()
            requests.append(request)
            return try await request.value()
        }
        
        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            requests[index].resume(returning: comments)
        }
        
        func completeCommentsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].resume(throwing: error)
        }
    }

}
