//
//  GrowingTextView.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-07-19.
//

import Foundation
import SwiftUI
import UIKit

final class ContentSizedTextView: UITextView {

    override var intrinsicContentSize: CGSize {
        return contentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        isScrollEnabled = false
        invalidateIntrinsicContentSize()
        layoutIfNeeded()
        isScrollEnabled = true
    }
}

struct GrowingTextView: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> ContentSizedTextView {
        let textView = ContentSizedTextView()
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = false
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ uiView: ContentSizedTextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextView
        
        init(_ parent: GrowingTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

