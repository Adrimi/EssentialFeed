//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by adrian.szymanowski on 11/10/2020.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropiate threads, if needed.
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
