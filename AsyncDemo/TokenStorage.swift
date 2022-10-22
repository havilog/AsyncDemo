//
//  TokenStorage.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/22.
//

import Foundation

protocol TokenSavable {
    func save(token: HaviToken, completion: @escaping (()) -> Void)
    func save(token: HaviToken) async
    func token() throws -> HaviToken
}

final class TokenStorage: TokenSavable {
    enum TokenError: Error {
        case empty
    }
    
    /// 이 큐가 왜 필요할까요?
    /// 
    /// data race를 방지하려면
    /// 1. serial + sync
    /// 2. ConcurrentQueue + DispatchBarrier
    /// 3. NSLock
    /// 4. DispatchSemaphore
    /// 중 택 1
    /// 
    /// 이를 대신하는게 actor
    private let tokenQueue: DispatchQueue = .init(label: "token_saving_serial_queue")
    private var tokenCache: [String: HaviToken] = .init()
    
    func save(token: HaviToken, completion: @escaping (()) -> Void) {
        tokenQueue.sync { [weak self] in
            defer { completion(()) }
            self?.tokenCache["havi_token"] = token
        }
    }
    
    func save(token: HaviToken) async {
        tokenQueue.sync { [weak self] in
            self?.tokenCache["havi_token"] = token
        }
    }
    
    func token() throws -> HaviToken {
        return try tokenQueue.sync { [weak self] in
            guard let token = self?.tokenCache["havi_token"] else { throw TokenError.empty }
            return token
        }
    }
}