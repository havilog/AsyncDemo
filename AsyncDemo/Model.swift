//
//  Model.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/22.
//

import Foundation

struct KakaoToken: Decodable {
    let accessToken: String
    let refreshToken: String
}

struct HaviRegister: Decodable {
    let user: String
}

struct HaviToken: Decodable {
    let accessToken: String
    let refreshToken: String
}
