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
    let baseURL = URL(string: "http://172.16.1.154:3000/assignment")!
    let pingURL = URL(string: "http://172.16.1.154:3000/ping")!

    public init(networkWrapper: NetworkWrapperCombine = .init()) {
        self.networkWrapper = networkWrapper
    }
    
    private func bundlePingRequest() -> URLRequest {
        var request = URLRequest(url: pingURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    func generateAssignment(subunit: SubUnit) -> AnyPublisher<Assignment, Error> {
        let url = baseURL.appendingPathComponent("/makeAssignment")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(subunit)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return networkWrapper.request(with: request, timeout: 120, pingURLRequest: bundlePingRequest(), pingTimeout: 3)
    }
}

struct Assignment: Codable {
    var questions: [String]
    var docID: String? = nil
}
