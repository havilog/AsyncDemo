//
//  LoginCompletion.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/22.
//

import Foundation

protocol HaviLoginable {
    var network: NetworkMockable { get }
    func login(completion: @escaping (Result<Void, Error>) -> Void)
    func kakaoLogin(
        dispatchGroup: DispatchGroup,
        completion: @escaping (Result<KakaoToken, Error>) -> Void
    )
    func haviRegister(
        dispatchGroup: DispatchGroup,
        completion: @escaping (Result<HaviRegister, Error>) -> Void
    )
    func haviLogin(
        kakaoToken: KakaoToken, 
        haviRegister: HaviRegister,
        completion: @escaping (Result<HaviToken, Error>) -> Void
    )
}

extension HaviLoginable {
    func login(completion: @escaping (Result<Void, Error>) -> Void) {
        var kakaoToken: KakaoToken?
        var register: HaviRegister?
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
                register = info
            case .failure:
                register = nil
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            guard let kakaoToken = kakaoToken, let register = register else { 
                completion(.failure(NSError(domain: "havi", code: 0)))
                return
            }
            
            haviLogin(
                kakaoToken: kakaoToken, 
                haviRegister: register
            ) { result in
                switch result {
                case let .success(haviToken):
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func kakaoLogin(
        dispatchGroup: DispatchGroup,
        completion: @escaping (Result<KakaoToken, Error>) -> Void
    ) {
        dispatchGroup.enter()
        network.fetch(
            endpoint: .kakaoToken, 
            mock: KakaoToken(accessToken: "kakao", refreshToken: "refresh"), 
            delay: .now() + 2
        ) { result in
            print(#function, "end")
            completion(result)
            dispatchGroup.leave()
        }
    }
    
    func haviRegister(
        dispatchGroup: DispatchGroup,
        completion: @escaping (Result<HaviRegister, Error>) -> Void
    ) {
        dispatchGroup.enter()
        network.fetch(
            endpoint: .register,
            mock: HaviRegister(user: "havi"),
            delay: .now() + 1
        ) { result in
            print(#function, "end")
            completion(result)
            dispatchGroup.leave()
        }
    }
    
    func haviLogin(
        kakaoToken: KakaoToken, 
        haviRegister: HaviRegister, 
        completion: @escaping (Result<HaviToken, Error>) -> Void
    ) {
        print(#function, "start")
        network.fetch(
            endpoint: .haviToken, 
            mock: HaviToken(accessToken: "havi access", refreshToken: "havi refersh"),
            delay: .now() + 1
        ) { result in 
            completion(result)
        }
    }
}

protocol TokenSavable {
    func save(token: HaviToken, completion: @escaping (Result<Void, Error>) -> Void)
}

extension TokenSavable {
    func save(token: HaviToken, completion: @escaping (Result<Void, Error>) -> Void) {
        fatalError("발급 받은 토큰을 저장한다.")
    }
}
