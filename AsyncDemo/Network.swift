//
//  Network.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/22.
//

import Foundation
import RxSwift

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
    
    func fetch<Model: Decodable>(
        endpoint: Endpoint,
        mock: Model,
        delay: DispatchTime
    ) -> Observable<Model> 
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
        delay: DispatchTime
    ) async throws -> Model {
        return try await withCheckedThrowingContinuation { continuation in
            fetch(endpoint: endpoint, mock: mock, delay: delay) { result in
                continuation.resume(with: result)
//                switch result {
//                case let .success(model):
//                    continuation.resume(returning: model)
//                case let .failure(error):
//                    continuation.resume(throwing: error)
//                }
            }
        }
    }
    
//    func fetch<Model: Decodable>(
//        endpoint: Endpoint,
//        mock: Model,
//        delay: UInt64
//    ) async throws -> Model {
//        try await Task.sleep(nanoseconds: delay)
//        return mock
//    }
    
    func fetch<Model: Decodable>(
        endpoint: Endpoint,
        mock: Model,
        delay: DispatchTime
    ) -> Observable<Model> {
        return .create { observer in
            self.fetch(endpoint: endpoint, mock: mock, delay: delay) { result in
                switch result {
                case let .success(model):
                    observer.onNext(model)
                    observer.onCompleted()
                    
                case let .failure(error):
                    observer.onError(error)
                }
            }    
            return Disposables.create()
        }
    }
}

struct NetworkMock: NetworkMockable { }
