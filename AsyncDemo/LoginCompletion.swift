//
//  LoginCompletion.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/22.
//

import Foundation

protocol HaviLoginable {
    func kakaoLogin(completion: @escaping (Result<KakaoToken, Error>) -> Void)
    func haviRegister(completion: @escaping (Result<HaviRegister, Error>) -> Void)
    func haviLogin(
        kakaoToken: KakaoToken, 
        haviRegister: HaviRegister,
        completion: @escaping (Result<HaviToken, Error>) -> Void
    )
}

protocol TokenSavable {
    func save(token: HaviToken, completion: @escaping (Result<Void, Error>) -> Void)
}
