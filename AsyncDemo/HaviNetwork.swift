//
//  HaviNetwork.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/24.
//

import Foundation

enum Endpoint {
    case kakaoLogin
    case haviRegister
    case haviLogin
}

protocol NetworkMockable {
    func fetch<Model: Decodable>(
        endpoint: Endpoint,
        mock: Model,
        delay: DispatchTime,
        completion: @escaping (Result<Model, Error>) -> Void
    )
    
    func fetch<Model: Decodable>(
        endpoint: Endpoint,
        mock: Model,
        delay: DispatchTime
    ) async throws -> Model
}

struct Network: NetworkMockable {
    func fetch<Model: Decodable>(
        endpoint: Endpoint,
        mock: Model,
        delay: DispatchTime,
        completion: @escaping (Result<Model, Error>) -> Void
    ) {
        DispatchQueue.global().asyncAfter(deadline: delay) {
            completion(.success(mock))
        }
    }
    
    func fetch<Model: Decodable>(
        endpoint: Endpoint,
        mock: Model,
        delay: DispatchTime
    ) async throws -> Model {
        
        
        return try await withCheckedThrowingContinuation { continuation in
            self.fetch(endpoint: endpoint, mock: mock, delay: delay) { result in
                switch result {
                case let .success(model):
                    continuation.resume(returning: model)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }    
        }
    }
}
