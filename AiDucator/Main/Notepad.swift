//
//  Notepad.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-13.
//

import SwiftUI

struct NotepadView: View {
    @State private var title: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    TextField("Title", text: $title)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    TextView(text: $notes)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    Button(action: saveButtonTapped) {
                        Text("Save")
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarTitle("Notepad", displayMode: .inline)
        }
    }
    
    func saveButtonTapped() {
        // Save the note
        print("Title: \(title)")
        print("Notes: \(notes)")
    }
}

struct TextView: UIViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let myTextView = UITextView()
        myTextView.delegate = context.coordinator

        return myTextView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView

        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }

        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
    }
}
