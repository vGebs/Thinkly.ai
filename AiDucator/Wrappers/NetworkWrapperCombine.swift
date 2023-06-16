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
        case pingFailed
    }
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func request<T: Decodable>(with urlRequest: URLRequest, timeout: TimeInterval, pingURLRequest: URLRequest? = nil, pingTimeout: TimeInterval = 5.0) -> AnyPublisher<T, Error> {
        if let pingRequest = pingURLRequest {
            return pingServer(with: pingRequest, timeout: pingTimeout)
                .flatMap { _ in
                    self.requestVoid(with: urlRequest, timeout: timeout)
                }
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
        } else {
            return requestVoid(with: urlRequest, timeout: timeout)
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
    }
}

@available(iOS 13.0, *)
extension NetworkWrapperCombine {
    private func requestVoid(with request: URLRequest, timeout: TimeInterval) -> AnyPublisher<Data, Error> {
        return session.dataTaskPublisher(for: request)
            .timeout(.seconds(timeout), scheduler: RunLoop.main, options: nil, customError: { URLError(.timedOut) })
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
    
    private func pingServer(with request: URLRequest, timeout: TimeInterval) -> AnyPublisher<Void, Error> {
        return session.dataTaskPublisher(for: request)
            .timeout(.seconds(timeout), scheduler: RunLoop.main, options: nil, customError: { URLError(.timedOut) })
            .mapError { NetworkError.unexpectedError($0) }
            .tryMap { (_, response) -> Void in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.pingFailed
                }
            }
            .eraseToAnyPublisher()
    }
}
