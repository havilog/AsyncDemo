//
//  LoginViewController.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/18.
//

import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: UI Property
    
    private let loginButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.setTitle("로그인 버튼", for: .init())
        return button
    }()
    
    private let textLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "아직 로그인 전 입니다!"
        return label
    }()
    
    internal let network: NetworkMockable = Network()
    internal let storage: TokenSavable = TokenStorage()
    private var loginTask: Task<Void, Never>
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
    
    // MARK: UI Configure
    
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
            textLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 50)
        ])
    }
    
    // MARK: Bind
    
    private func bind() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    @objc
    private func loginButtonTapped() {
        self.loginTask = Task {
            do {
                try await loginAsync()
                textLabel.text = "로그인 성공"
            }
            catch {
                textLabel.text = "로그인 실패"
            }
        }
        loginTask.cancel()
    }
}

extension LoginViewController: AsyncLoginable {}

extension ObservableType {
    var value: Element {
        get async throws {
            let disposable = SingleAssignmentDisposable()
            return try await withTaskCancellationHandler(
                operation: { 
                    try await withCheckedThrowingContinuation { continuation in
                        var didResume: Bool = false
                        disposable.setDisposable(
                            self.subscribe(
                                onNext: { element in
                                    guard didResume == false else { return }
                                    continuation.resume(returning: element)
                                    didResume = true
                                }, 
                                onError: { error in
                                    guard didResume == false else { return }
                                    continuation.resume(throwing: error)
                                    didResume = true
                                }
                            )
                        )
                    }
                }, 
                onCancel: { [disposable] in 
                    disposable.dispose()
                }
            )
        }
    }
}
