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
}
