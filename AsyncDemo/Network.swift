//
//  Network.swift
//  AsyncDemo
//
//  Created by 한상진 on 2022/10/22.
//

import Foundation

struct Network {
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
}
