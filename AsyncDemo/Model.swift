//
//  Model.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/24.
//

import Foundation

struct KakaoToken: Decodable {
    let accessToken: String
    let refreshToken: String
}

extension KakaoToken {
    static var mock: Self = .init(accessToken: "kakao_access_token", refreshToken: "kakao_refresh_token")
}

struct HaviUserInfo: Decodable {
    let user: String
}

extension HaviUserInfo {
    static var mock: Self = .init(user: "havi.log")
}

struct HaviToken: Decodable {
    let accessToken: String
    let refreshToken: String
}

extension HaviToken {
    static var mock: Self = .init(accessToken: "havi_access_token", refreshToken: "havi_refresh_token")
}

