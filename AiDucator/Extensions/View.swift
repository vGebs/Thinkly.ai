//
//  View.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
