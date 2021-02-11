//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 11/02/2021.
//

import Foundation

extension HTTPURLResponse {
    private static var ACK_200: UInt { 200 }
    
    var isOK: Bool {
        statusCode == HTTPURLResponse.ACK_200
    }
}
