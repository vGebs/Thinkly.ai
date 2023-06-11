//
//  NetworkWrapperCombine.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-10.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public class NetworkWrapperCombine {
    public enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case statusCode(Int)
        case decodingError
        case unexpectedError(Error)
    }
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func request<T: Decodable>(with urlRequest: URLRequest) -> AnyPublisher<T, Error> {
        return requestVoid(with: urlRequest)
            .tryMap { (data) -> T in
                return try JSONDecoder().decode(T.self, from: data)
            }
            .mapError{ error -> Error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return error
            }
            .eraseToAnyPublisher()
    }

//    public func request(with urlRequest: URLRequest) -> AnyPublisher<Data, Error> {
//        return requestVoid(with: urlRequest)
//            .mapError{ error -> Error in
//                if let networkError = error as? NetworkError {
//                    return networkError
//                }
//                return error
//            }
//            .eraseToAnyPublisher()
//    }
}

@available(iOS 13.0, *)
extension NetworkWrapperCombine {
    private func requestVoid(with request: URLRequest) -> AnyPublisher<Data, Error> {
        return session.dataTaskPublisher(for: request)
            .mapError { NetworkError.unexpectedError($0) }
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.statusCode(httpResponse.statusCode)
                }
                return data
            }
            .eraseToAnyPublisher()
    }
}
