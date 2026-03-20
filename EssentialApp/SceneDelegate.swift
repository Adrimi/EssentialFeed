//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Adrian Szymanowski on 15/02/2021.
//

import os
import UIKit
import CoreData
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private lazy var logger = Logger(subsystem: "com.adrimi.EssentialAppCaseStudy", category: "main")
    
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            return try CoreDataFeedStore(
                storeURL: NSPersistentContainer
                    .defaultDirectoryURL()
                    .appendingPathComponent("feed-store.sqlite"))
        } catch {
            logger.fault("CoreData store failed to instantiate with error: \(error.localizedDescription)")
            return NullStore()
        }
    }()
    
    private lazy var localFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var navigationController: UINavigationController = {
        UINavigationController(
            rootViewController: FeedUIComposer.feedComposedWith(
                feedLoader: makeRemoteFeedloaderWithLocalFallback,
                imageLoader: makeLocalImageLoaderWithRemoteFallback,
                selection: showComments))
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    /// Ideally you would like to call this method, but you can't. Thus all logis, that I implement are moved to `configureWindow` method
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func showComments(for image: FeedImage) {
        let url = baseURL.appendingPathComponent("/v1/image/\(image.id)/comments")
        let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
        navigationController.pushViewController(comments, animated: true)
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        Task {
            try? await localFeedLoader.validateCache()
        }
    }
    
    private func makeRemoteCommentsLoader(url: URL) -> () async throws -> [ImageComment] {
        { [httpClient] in
            let (data, response) = try await httpClient.get(from: url)
            return try ImageCommentsMapper.map(data, from: response)
        }
    }
    
    private func makeRemoteFeedloaderWithLocalFallback() async throws -> Paginated<FeedImage> {
        do {
            let items = try await makeRemoteFeedLoader()
            try? await localFeedLoader.save(items)
            return makeFirstPage(items: items)
        } catch {
            return makeFirstPage(items: try await localFeedLoader.load())
        }
    }

    private func makeRemoteLoadMoreLoader(last: FeedImage?) async throws -> Paginated<FeedImage> {
        async let cachedItems = localFeedLoader.load()
        async let newItems = makeRemoteFeedLoader(after: last)

        let cached = try await cachedItems
        let new = try await newItems
        let merged = cached + new
        let page = makePage(items: merged, last: new.last)
        try? await localFeedLoader.save(merged)
        return page
    }
    
    private func makeRemoteFeedLoader(after image: FeedImage? = nil) async throws -> [FeedImage] {
        let url = FeedEndpoint.get(after: image).url(baseURL: baseURL)
        let (data, response) = try await httpClient.get(from: url)
        return try FeedItemsMapper.map(data, from: response)
    }

    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }
    
    private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(
            items: items,
            loadMore: last.map { last in
                { try await self.makeRemoteLoadMoreLoader(last: last) }
            }
        )
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) async throws -> Data {
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        do {
            return try await localImageLoader.loadImageData(from: url)
        } catch {
            let (data, response) = try await httpClient.get(from: url)
            let imageData = try FeedImageDataMapper.map(data, from: response)
            try? await localImageLoader.save(imageData, for: url)
            return imageData
        }
    }
}
