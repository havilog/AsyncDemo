//
//  TokenStorage.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/22.
//

import Foundation

protocol TokenSavable {
    func save(token: HaviToken, completion: @escaping (()) -> Void)
}

protocol TokenAsyncSavable {
    func save(token: HaviToken) async
    func token() async throws -> HaviToken
}

enum TokenError: Error {
    case invalidToken
}

final actor TokenStorage: TokenAsyncSavable {
    private let tokenKey: String = "havi_token"
    private var tokenCache: [String: HaviToken] = .init()
    
    nonisolated func save(token: HaviToken, completion: @escaping (()) -> Void) {
        fatalError()
    }
    
    /// 원래는 뭔가 저장소를 동기화하고, 임시토큰일 경우 예외처리하는 로직들이 들어갈거에요
    func save(token: HaviToken) {
        tokenCache[tokenKey] = token
    }
    
    func token() throws -> HaviToken {
        guard let token = tokenCache[tokenKey] else { throw TokenError.invalidToken }
        return token
    }
}

//final class TokenStorage: TokenSavable {
//    /// 이 큐가 왜 필요할까요?
//    /// 
//    /// data race를 방지하려면
//    /// 1. serial + sync
//    /// 2. ConcurrentQueue + DispatchBarrier
//    /// 3. NSLock
//    /// 4. DispatchSemaphore
//    /// 중 택 1
//    /// 
//    /// 이를 대신하는게 actor
//    private let tokenQueue: DispatchQueue = .init(label: "token_saving_serial_queue")
//    
//    /// 원래는 메모리가 아니라 유저디폴트나 이런데 저장할거에요
//    private var tokenCache: [String: HaviToken] = .init()
//    
//    func save(token: HaviToken, completion: @escaping (()) -> Void) {
//        tokenQueue.sync { [weak self] in
//            defer { completion(()) }
//            self?.tokenCache["havi_token"] = token
//        }
//    }
//    
//    func save(token: HaviToken) async {
//        tokenQueue.sync { [weak self] in
//            self?.tokenCache["havi_token"] = token
//        }
//    }
//    
//    func token() throws -> HaviToken {
//        return try tokenQueue.sync { [weak self] in
//            guard let token = self?.tokenCache["havi_token"] else { throw TokenError.empty }
//            return token
//        }
//    }
//}
