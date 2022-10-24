//
//  Loginable.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/24.
//

import Foundation

protocol Loginable {
    var network: NetworkMockable { get }
    var storage: TokenSavable { get }
    func login(completion: @escaping (Result<Void, Error>) -> Void)
    
    func kakaoLogin(dispatchGroup: DispatchGroup, completion: @escaping (Result<KakaoToken, Error>) -> Void)
    
    func haviRegister(dispatchGroup: DispatchGroup, completion: @escaping (Result<HaviUserInfo, Error>) -> Void)
    
    func haviLogin(
        kakaoToken: KakaoToken,
        haviUserinfo: HaviUserInfo,
        completion: @escaping (Result<HaviToken, Error>) -> Void
    )
}

extension Loginable {
    
    func login(completion: @escaping (Result<Void, Error>) -> Void) {
        var kakaoToken: KakaoToken?
        var haviUserInfo: HaviUserInfo?
        let dispatchGroup: DispatchGroup = .init()
        
        kakaoLogin(dispatchGroup: dispatchGroup) { result in
            switch result {
            case let .success(token):
                kakaoToken = token
            case .failure:
                kakaoToken = nil
            }
        }
        
        haviRegister(dispatchGroup: dispatchGroup) { result in
            switch result {
            case let .success(info):
                haviUserInfo = info
            case .failure:
                haviUserInfo = nil
            }
        }
        
        
        
        dispatchGroup.notify(queue: .global()) {
            guard let kakaoToken = kakaoToken, let haviUserInfo = haviUserInfo else { 
                completion(.failure(NSError(domain: "login", code: 11)))
                return
            }
            
            haviLogin(kakaoToken: kakaoToken, haviUserinfo: haviUserInfo) { result in
                switch result {
                case let .success(haviToken):
//                    storage.save(haviToken: haviToken)
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func kakaoLogin(dispatchGroup: DispatchGroup, completion: @escaping (Result<KakaoToken, Error>) -> Void) {
        dispatchGroup.enter()
        print(#function, "start")
        defer { print(#function, "end") }
        network.fetch(endpoint: .haviLogin, mock: KakaoToken.mock, delay: .now() + 1) { result in
            completion(result)
            dispatchGroup.leave()
        }
    }
    
    func haviRegister(dispatchGroup: DispatchGroup, completion: @escaping (Result<HaviUserInfo, Error>) -> Void) {
        dispatchGroup.enter()
        print(#function, "start")
        defer { print(#function, "end") }
        network.fetch(endpoint: .haviRegister, mock: HaviUserInfo.mock, delay: .now() + 2) { result in
            completion(result)
            dispatchGroup.leave()
        }
    }
    
    func haviLogin(
        kakaoToken: KakaoToken,
        haviUserinfo: HaviUserInfo,
        completion: @escaping (Result<HaviToken, Error>) -> Void
    ) {
        print(#function, "start")
        defer { print(#function, "end") }
        network.fetch(endpoint: .haviLogin, mock: HaviToken.mock, delay: .now() + 1) { result in
            completion(result)
        }
    }
}

