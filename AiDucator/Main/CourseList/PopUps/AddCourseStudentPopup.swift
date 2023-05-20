//
//  AddCourseStudentPopup.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-19.
//

import Foundation
import SwiftUI

struct AddCourseStudentPopup: View {
    @ObservedObject var classListViewModel: CourseListViewModel
    @Binding var addClassPressed: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.black)
            
            RoundedRectangle(cornerRadius: 25)
                .stroke(lineWidth: 4)
                .foregroundColor(.buttonPrimary)
            
            header
            
            VStack {
                Spacer()
                    .padding(.top, 50)
                
                addClassID
                
                actionButton
            }
            
        }
        .onTapGesture {
            hideKeyboard()
        }
        .frame(width: screenWidth * 0.9, height: screenHeight / 4)
    }
    
    var header: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            hideKeyboard()
                            addClassPressed = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.buttonPrimary)
                    }
                    .padding(.top)
                    .padding(.leading)
                    Spacer()
                }
                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Text("Add Course")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top)
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
    @State var docID: String = ""
    @State var textIsValid = true
    
    var addClassID: some View {
        HStack {
            TextFieldView(
                outputText: $docID,
                inputWarning: $textIsValid,
                title: "Course Title",
                imageString: "newspaper",
                phoneOrTextfield: .textfield,
                warning: "",
                isSecureField: false
            )
        }
        .padding(.top,2)
    }
    
    var actionButton: some View{
        VStack{
            Button(action: {
                hideKeyboard()
                
                classListViewModel.enrollInCourse(id: docID)
                
                withAnimation {
                    self.addClassPressed = false
                }
            }){
                ZStack{
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(lineWidth: 2.5)
                        .foregroundColor(Color.buttonPrimary)
                    
                    HStack {
                        Spacer()
                        if docID.count != 20 {
                            Image(systemName: "lock")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        } else {
                            Image(systemName: "lock.open")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        
                        Text("Add Course")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical)
            .padding(.top, 3)
            .disabled(docID.count != 20)
            .opacity(docID.count == 20 ? 1 : 0.4)
        }
    }
}
