//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by adrian.szymanowski on 11/10/2020.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL) async throws -> (Data, HTTPURLResponse)
}
