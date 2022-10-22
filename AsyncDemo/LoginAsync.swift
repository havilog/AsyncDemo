//
//  LoginAsync.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/22.
//

import Foundation

protocol HaviAsyncLoginable {
    var network: NetworkMockable { get }
    var tokenStorage: TokenSavable { get }
    func login() async throws 
    func kakaoLogin() async throws -> KakaoToken
    func haviRegister() async throws -> HaviRegister
    func haviLogin(kakaoToken: KakaoToken, haviRegister: HaviRegister) async throws -> HaviToken
}

extension HaviAsyncLoginable {
    func login() async throws {
        async let kakaoToken = try await kakaoLogin()
        async let haviRegister = try await haviRegister()
        let haviToken = try await haviLogin(kakaoToken: kakaoToken, haviRegister: haviRegister)
        await tokenStorage.save(token: haviToken)
    }
    
    func kakaoLogin() async throws -> KakaoToken {
        let kakaoToken = try await network.fetch(endpoint: .kakaoToken, mock: KakaoToken.init(accessToken: "", refreshToken: ""), delay: NSEC_PER_SEC)
        return kakaoToken
    }
    
    func haviRegister() async throws -> HaviRegister {
        let haviRegister = try await network.fetch(endpoint: .register, mock: HaviRegister.init(user: ""), delay: NSEC_PER_SEC * 2)
        return haviRegister
    }
    
    func haviLogin(kakaoToken: KakaoToken, haviRegister: HaviRegister) async throws -> HaviToken {
        let haviToken = try await network.fetch(endpoint: .haviToken, mock: HaviToken(accessToken: "", refreshToken: ""), delay: NSEC_PER_SEC)
        return haviToken
    }
}
