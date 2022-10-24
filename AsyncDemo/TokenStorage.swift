//
//  TokenStorage.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/24.
//

import Foundation

protocol TokenSavable {
    func save(haviToken: HaviToken) async
}

final actor TokenStorage: TokenSavable {
    private static let key: String = "havi_token"
    private var cache: [String: HaviToken] = .init()
    
    func save(haviToken: HaviToken) {
        cache[Self.key] = haviToken
    }
}

//struct TokenStorage: TokenSavable {
//    private static let key: String = "havi_token"
//    // 1번 dispatchqueue serial + sync
//    // 2번 NSLock()
//    // 3번 concurrent queue + dispatch barrier
//    // 4번 dispatch semaphore
//    private let tokenQueue: DispatchQueue = .init(label: "serial_queue")
//    private var cache: [String: HaviToken] = .init()
//    
//    func save(haviToken: HaviToken) {
//        tokenQueue.sync {
//            cache[Self.key] = haviToken    
//        }
//    }
//}
