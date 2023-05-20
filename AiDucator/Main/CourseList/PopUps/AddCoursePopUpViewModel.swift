//
//  AddCoursePopUpViewModel.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import Combine
import Foundation

class AddCoursePopUpViewModel: ObservableObject {
    @Published var className: String = ""
    @Published var classDescription: String = ""
    @Published var durationFrom = Date()
    @Published var durationTo = Date()
    @Published var selectedClassType = ClassType(id: "Math", sfSymbol: "function")
    
    @Published var titleIsValid = false
    @Published var descriptionIsValid = false
    @Published var endDateValid = false
    
    private var cancellables: [AnyCancellable] = []
    
    init() {
        $className
            .sink { [weak self] title in
                if title.count > 3 {
                    self?.titleIsValid = true
                } else {
                    self?.titleIsValid = false
                }
            }.store(in: &cancellables)
    }
}
