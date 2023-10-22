//
//  AssignmentCreationService.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-08-10.
//

import Foundation
import Combine

class AssignmentCreationService {
    private let networkWrapper: NetworkWrapperCombine
//    let baseURL = URL(string: "http://172.16.1.154:3000/assignment")!
//    let pingURL = URL(string: "http://172.16.1.154:3000/ping")!

    @Published var baseURL: URL?
    @Published var pingURL: URL?
    
    private var cancellables: [AnyCancellable] = []
    
    public init(networkWrapper: NetworkWrapperCombine = .init()) {
        self.networkWrapper = networkWrapper
        
        AppState.shared.$backend_BaseUrl
            .sink { [weak self] url in
                if let url = url {
                    self?.baseURL = url.appendingPathComponent("/assignment")
                    self?.pingURL = url.appendingPathComponent("/ping")
                }
            }.store(in: &cancellables)
    }
    
    private func bundlePingRequest() -> URLRequest? {
        if let pingURL = pingURL {
            var request = URLRequest(url: pingURL)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return request
        }
        
        return nil
    }
    
    enum URLError: Error {
        case noBaseURL
    }
    
    func generateAssignment(subunit: GenerateAssignment_Input) -> AnyPublisher<Assignment, Error> {
        if let baseURL = baseURL {
            let url = baseURL.appendingPathComponent("/makeAssignment")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try? JSONEncoder().encode(subunit)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return networkWrapper.request(with: request, timeout: 120, pingURLRequest: bundlePingRequest(), pingTimeout: 3)
        } else {
            return Fail(error: URLError.noBaseURL).eraseToAnyPublisher()
        }
    }
}

struct GenerateAssignment_Input: Codable {
    var subunit: SubUnit
    var uid: String
}

struct Assignment: Codable {
    var questions: [String]
    var docID: String? = nil
}
