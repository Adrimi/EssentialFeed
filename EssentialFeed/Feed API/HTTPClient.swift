//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by adrian.szymanowski on 11/10/2020.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
