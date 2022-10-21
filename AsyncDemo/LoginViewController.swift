//
//  LoginViewController.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/18.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {
    
    private let loginButton: UIButton = {
        let button: UIButton = .init(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("로그인 버튼", for: .init())
        button.setTitleColor(.black, for: .init())
        return button
    }()
    
    private let textLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "아직 로그인 전 입니다!"
        return label
    }()
    
    private let network: HaviNetwork = .init()
    private let storage: TokenStorage = .init()
    
    private var disposeBag: DisposeBag = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(loginButton)
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 100),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10)
        ])
    }
    
    private func bind() {
//        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.loginRxSwift()
            })
            .disposed(by: disposeBag)
    }
    
    @objc
    private func login() {
//        loginWithCompletion()
    }
}

// MARK: completion

extension LoginViewController {
    private func loginWithCompletion() {
        var kakaoToken: KakaoToken?
        var register: Register?
        
        let group = DispatchGroup()
        
        group.enter()
        haviRegister { result in
            print("register login")
            group.leave()
            switch result {
            case .success(let success):
                register = success
            case .failure:
                register = nil
            }
        } 
        
        group.enter()
        kakaoLogin { result in
            print("kakao login")
            group.leave()
            switch result {
            case .success(let success):
                kakaoToken = success
            case .failure:
                kakaoToken = nil
            }
        }
        
        group.notify(queue: .global()) { [weak self] in
            print("kakao login, havi register 끝남")
            guard let kakaoToken = kakaoToken, let register = register else {
                DispatchQueue.main.async {
                    self?.textLabel.text = "에러에러 ㅠㅠ"
                }
                return
            }
            self?.haviLogin(kakaoToken: kakaoToken, register: register) { result in
                switch result {
                case let .success(result):
                    print("havi login success")
                    self?.storage.save(token: result) { _ in
                        DispatchQueue.main.async {
                            self?.textLabel.text = "로그인 성공성공~"
                        }
                    }
                case .failure:
                    DispatchQueue.main.async {
                        self?.textLabel.text = "에러에러 ㅠㅠ"
                    }
                }
            }
        }
    }
}

extension LoginViewController {
    private func kakaoLogin(completion: @escaping (Result<KakaoToken, Error>) -> Void) {
        network.fetch(endpoint: .kakaoToken, delay: .now() + 1) { _ in
            completion(.success(.init(accessToken: "123", refreshToken: "456")))
        }
    }

    private func haviRegister(completion: @escaping (Result<Register, Error>) -> Void) {
        network.fetch(endpoint: .register, delay: .now() + 1) { _ in
            completion(.success(.init()))    
        }
    }

    private func haviLogin(
        kakaoToken: KakaoToken, 
        register: Register,
        completion: @escaping (Result<HaviToken, Error>) -> Void
    ) {
        network.fetch(endpoint: .haviToken, delay: .now() + 1) { _ in
            completion(.success(.init(accessToken: "123", refreshToken: "456")))    
        }
    }
}

// MARK: rxswift

extension LoginViewController {
    private func loginRxSwift() {
        Observable.zip(kakaoLogin(), haviRegister())
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMapLatest { [weak self] kakaoToken, register -> Observable<HaviToken> in
                guard let self = self else { return .empty() }
                return self.haviLogin(token: kakaoToken, register: register)
            }
            .flatMapLatest { [weak self] haviToken -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.storage.save(token: haviToken)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] haviToken in
                    self?.textLabel.text = "로그인 성공성공~"
                },
                onError: { [weak self] _ in
                    self?.textLabel.text = "에러에러 ㅠㅠ"
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func kakaoLogin() -> Observable<KakaoToken> {
        return network.fetch(endpoint: .kakaoToken, delay: .now() + 1)
            .map { _ in return KakaoToken.init(accessToken: "!23", refreshToken: "123") }
    }
    
    private func haviRegister() -> Observable<Register> {
        return network.fetch(endpoint: .register, delay: .now() + 2)
            .map { _ in return Register() }
    }
    
    private func haviLogin(token: KakaoToken, register: Register) -> Observable<HaviToken> {
        return network.fetch(endpoint: .haviToken, delay: .now() + 0.5)
            .map { _ in return HaviToken.init(accessToken: "!23", refreshToken: "123") }
    }
}

// MARK: storage

final class TokenStorage {
    /// data race를 방지하려면
    /// 1. serial + sync
    /// 2. ConcurrentQueue + DispatchBarrier
    /// 3. NSLock
    /// 4. DispatchSemaphore
    /// 중 택 1
    private let tokenQueue: DispatchQueue = .init(label: "token_saving_serial_queue") // default = serial
    private var cache: [String: HaviToken] = .init()
    
    func save(token: HaviToken, completion: @escaping (()) -> Void) {
        tokenQueue.sync { [weak self] in
            self?.cache["havi_token"] = token
            completion(())
        }
    }
    
    func save(token: HaviToken) -> Observable<Void> {
        return .create { [weak self] observer in
            self?.tokenQueue.sync {
                self?.cache["havi_token"] = token
                observer.onNext(())
            }
            
            return Disposables.create()
        } 
    }
}

// MARK: network

struct HaviNetwork {
    func fetch(
        endpoint: Endpoint,
        delay: DispatchTime,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        DispatchQueue.global().asyncAfter(deadline: delay) {
            completion(.success(()))
        }
    }
    
    func fetch(
        endpoint: Endpoint,
        delay: DispatchTime
    ) -> Observable<Void> {
        return .create { observer in
            DispatchQueue.global().asyncAfter(deadline: delay) {
                observer.onNext(())
            }
            return Disposables.create()
        }
    }
}

// MARK: model

enum Endpoint {
    case kakaoToken
    case register
    case haviToken
}

struct KakaoToken: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String
}

struct Register: Decodable { }

struct HaviToken: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String
}
