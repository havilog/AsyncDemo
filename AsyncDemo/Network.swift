//
//  Network.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/22.
//

import Foundation

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
        delay: UInt64
    ) async throws -> Model
}

extension NetworkMockable {
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
        delay: UInt64
    ) async throws -> Model {
        try await Task.sleep(nanoseconds: delay)
        return mock
    }
}

struct NetworkMock: NetworkMockable { }
