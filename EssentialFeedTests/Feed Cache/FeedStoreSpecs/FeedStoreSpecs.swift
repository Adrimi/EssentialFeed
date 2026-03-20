//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by adrian.szymanowski on 22/11/2020.
//

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() async
    func test_retrieve_hasNoSideEffectsOnEmptyCache() async
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() async
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() async
    
    func test_insert_deliversNoErrorOnEmptyCache() async
    func test_insert_deliversNoErrorOnNonEmptyCache() async
    func test_insert_overridesPreviouslyInsertedCacheValues() async
    
    func test_delete_deliversNoErrorOnEmptyCache() async
    func test_delete_hasNoSideEffectsOnEmptyCache() async
    func test_delete_deliversNoErrorOnNonEmptyCache() async
    func test_delete_emptiesPreviouslyInsertedCache() async
    
    func test_storeSideEffects_runSerially() async
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRretrievalError() async
    func test_retrieve_hasNoSideEffectsOnFailure() async
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError() async
    func test_insert_hasNoSideEffectsOnInsertionError() async
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError() async
    func test_delete_hasNoSideEffectsOnDeletionError() async
}

typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
