//
//  LoginViewController.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/18.
//

import UIKit

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
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
    }
    
    @objc
    private func login() {
        // kakaoToken
        // haviRegister
        // haviLogin
        // saveToken
    } 
}

extension LoginViewController: HaviLoginable {
    func kakaoLogin(completion: @escaping (Result<KakaoToken, Error>) -> Void) {
        fatalError("네트워크를 찔러서 카카오 토큰을 가져온다.")
    }
    
    func haviRegister(completion: @escaping (Result<HaviRegister, Error>) -> Void) {
        fatalError("하비 앱 가입을 찔러서 결과를 가져온다.") 
    }
    
    func haviLogin(kakaoToken: KakaoToken, haviRegister: HaviRegister, completion: @escaping (Result<HaviToken, Error>) -> Void) {
        fatalError("위 두개의 api가 다 끝난 뒤, 토큰과 결과값으로 haviToken을 발급받는다.")
    }
}

extension LoginViewController: TokenSavable {
    func save(token: HaviToken, completion: @escaping (Result<Void, Error>) -> Void) {
        fatalError("발급 받은 토큰을 저장한다.")
    }
}
