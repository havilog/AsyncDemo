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
    
    private let network: HaviNetwork = .init()
    
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
        print("hi")
    }
}

struct HaviNetwork {
    func fetch<Model: Decodable>(
        endpoint: Endpoint, 
        completion: @Sendable @escaping (Result<Model, Error>) -> Void
    ) {
        // request는 대충 만들거에요
        let url: URL = .init(string: endpoint.urlString)!
        let request: URLRequest = .init(url: url)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                // 이런 곳에서 return을 빼먹을 수 있음
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError.init(domain: "havi", code: 123)))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(Model.self, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }
    }
}

enum Endpoint {
    case kakaoToken
    case register
    case haviToken
}

extension Endpoint {
    var urlString: String {
        return "havi ZZang"
    }
}
