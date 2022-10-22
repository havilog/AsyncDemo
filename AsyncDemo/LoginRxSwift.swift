//
//  LoginRxSwift.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/22.
//

import Foundation
import RxSwift

protocol HaviRxLoginable {
    var network: NetworkMockable { get }
    var tokenStorage: TokenRxSaveble { get }
    func loginRxSwift() -> Observable<Void>
    func kakaoLogin() -> Observable<KakaoToken>
    func haviRegister() -> Observable<HaviRegister>
    func haviLogin(kakaoToken: KakaoToken, register: HaviRegister) -> Observable<HaviToken>
}

extension HaviRxLoginable {
    func loginRxSwift() -> Observable<Void> {
        Observable.zip(
            kakaoLogin().do(onNext: { _ in print("kakao login end") }), 
            haviRegister().do(onNext: { _ in print("havi register end") })
        )
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMapLatest { kakaoToken, register -> Observable<HaviToken> in
                return haviLogin(kakaoToken: kakaoToken, register: register)
            }
            .flatMapLatest { haviToken -> Observable<Void> in
                print("havi login end")
                return tokenStorage.save(token: haviToken)
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { _ in print("token save end") })
    }
    
    func kakaoLogin() -> Observable<KakaoToken> {
        return network.fetch(endpoint: .kakaoToken, mock: KakaoToken.mock, delay: .now() + 1)
    }
    
    func haviRegister() -> Observable<HaviRegister> {
        return network.fetch(endpoint: .register, mock: HaviRegister.mock, delay: .now() + 2)
    }
    func haviLogin(kakaoToken: KakaoToken, register: HaviRegister) -> Observable<HaviToken> {
        defer { print("havi login start") }
        return network.fetch(endpoint: .haviToken, mock: HaviToken.mock, delay: .now() + 1)
    }
}
