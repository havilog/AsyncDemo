//
//  AsyncLoginable.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/24.
//

import Foundation

protocol AsyncLoginable {
    var network: NetworkMockable { get }
    var storage: TokenSavable { get }
    func loginAsync() async throws
    func kakaoLogin() async throws -> KakaoToken 
    func haviRegister() async throws -> HaviUserInfo
    func haviLogin(kakaoToken: KakaoToken, haviUserInfo: HaviUserInfo) async throws -> HaviToken
}

extension AsyncLoginable {
    func loginAsync() async throws {
        async let kakaoToken = try await kakaoLogin()
        async let haviUserInfo = try await haviRegister()
        let haviToken = try await haviLogin(kakaoToken: kakaoToken, haviUserInfo: haviUserInfo)
        await storage.save(haviToken: haviToken)
    }
    
    func kakaoLogin() async throws -> KakaoToken {
        print(#function, "start")
        let kakaoToken = try await network.fetch(endpoint: .kakaoLogin, mock: KakaoToken.mock, delay: .now() + 1)
        print(#function, "end")
        return kakaoToken
    }
    
    func haviRegister() async throws -> HaviUserInfo {
        print(#function, "start")
        let haviRegister = try await network.fetch(endpoint: .haviRegister, mock: HaviUserInfo.mock, delay: .now() + 2)
        print(#function, "end")
        return haviRegister
    }
    
    func haviLogin(kakaoToken: KakaoToken, haviUserInfo: HaviUserInfo) async throws -> HaviToken {
        print(#function, "start")
        let haviToken = try await network.fetch(endpoint: .haviLogin, mock: HaviToken.mock, delay: .now() + 1)
        print(#function, "end")
        return haviToken
    }
}
