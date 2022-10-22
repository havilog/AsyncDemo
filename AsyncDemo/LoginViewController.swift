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
    
    internal let network: NetworkMockable = NetworkMock()
//    let tokenStorage: TokenSavable = TokenStorage()
//    internal let tokenStorage: TokenAsyncSavable = TokenActorStorage() 
    let tokenStorage: TokenRxSaveble = TokenRxStorage()
    private let disposeBag: DisposeBag = .init()
    
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
    internal func login() {
//        login { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    self?.textLabel.text = "성공"
//                case .failure:
//                    self?.textLabel.text = "실패"
//                }
//            }
//        }
//        Task { @MainActor in
//            do {
//                try await loginAsync()
//                textLabel.text = "성공"
//            }
//            catch {
//                textLabel.text = "실패"
//            }
//        }
        loginRxSwift()
            .subscribe { [weak self] _ in
                self?.textLabel.text = "성공"
            } onError: { [weak self] error in
                self?.textLabel.text = "실패"
            }
            .disposed(by: disposeBag)

    } 
}

//extension LoginViewController: HaviLoginable { }
//extension LoginViewController: HaviAsyncLoginable { }
extension LoginViewController: HaviRxLoginable { }
