//
//  Created by Adrian Szymanowski on 16/01/2021.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    private let loader: () async throws -> Resource
    private var task: Task<Void, Never>?
    private var activeTaskID: UUID?
    private var isLoading = false
    
    var presenter: LoadResourcePresenter<Resource, View>?
    
    init(loader: @escaping () async throws -> Resource) {
        self.loader = loader
    }
    
    func loadResource() {
        guard !isLoading else { return }
        
        presenter?.didStartLoading()
        isLoading = true
        let taskID = UUID()
        activeTaskID = taskID

        task = Task { [weak self] in
            do {
                guard let self else { return }
                let resource = try await self.loader()
                await self.finishLoading(taskID: taskID, with: .success(resource))
            } catch is CancellationError {
                guard let self else { return }
                await self.cancelLoading(taskID: taskID)
            } catch {
                guard let self else { return }
                await self.finishLoading(taskID: taskID, with: .failure(error))
            }
        }
    }

    private func finishLoading(taskID: UUID, with result: Result<Resource, Error>) async {
        await MainActor.run { [weak self] in
            guard let self, self.activeTaskID == taskID else { return }

            switch result {
            case let .success(resource):
                presenter?.didFinishLoading(with: resource)
            case let .failure(error):
                presenter?.didFinishLoading(with: error)
            }

            reset()
        }
    }

    private func cancelLoading(taskID: UUID) async {
        await MainActor.run { [weak self] in
            guard let self, self.activeTaskID == taskID else { return }
            reset()
        }
    }

    private func reset() {
        task = nil
        activeTaskID = nil
        isLoading = false
    }

    deinit {
        task?.cancel()
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }
    
    func didCancelImageRequest() {
        task?.cancel()
        reset()
    }
}
