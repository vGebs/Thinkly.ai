//
//  NavBar.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import SwiftUI
import Combine

struct NavBar: View {
    @Binding var offset: CGFloat
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.black)
                    .opacity(0.85)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: 4)
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    //MARK: - Notes
                    HStack {
                        Image(systemName: "note.text")
                            .font(.system(
                                size: 20,
                                weight: self.offset >= 0 && self.offset < (screenWidth - screenWidth * 0.5) ? .bold : .light,
                                design: .rounded
                            ))
                            .foregroundColor(self.offset >= 0 && self.offset < (screenWidth - screenWidth * 0.5) ? .accent : .primary)
                            .padding(.leading)
                            .onTapGesture {
                                withAnimation{
                                    self.offset = 0
                                }
                            }
                        
                        Image(systemName: "poweron")
                            .font(.system(
                                size: 11,
                                weight: .light,
                                design: .rounded
                            ))
                            .foregroundColor(.white)
                            .opacity(offset == 0 ? 1 : 0)
                    }
                    
                    Spacer()
                    
                    //MARK: - Assignments
                    HStack {
                        Image(systemName: "poweron")
                            .font(.system(
                                size: 11,
                                weight: .light,
                                design: .rounded
                            ))
                            .foregroundColor(.white)
                            .opacity(offset == screenWidth ? 1 : 0)
                        
                        Image(systemName: "tray")
                            .font(.system(
                                    size: 20,
                                    weight: self.offset >= screenWidth * 0.5 && self.offset < ((screenWidth * 2) - screenWidth * 0.5) ? .bold : .light,
                                    design: .rounded
                            ))
                            .foregroundColor(self.offset >= screenWidth * 0.5 && self.offset < ((screenWidth * 2) - screenWidth * 0.5) ? .accent : .primary)
                            .onTapGesture {
                                withAnimation{
                                    self.offset = screenWidth
                                }
                            }
                        
                        Image(systemName: "poweron")
                            .font(.system(
                                size: 11,
                                weight: .light,
                                design: .rounded
                            ))
                            .foregroundColor(.white)
                            .opacity(offset == screenWidth ? 1 : 0)
                    }
                    
                    Spacer()
                    
                    //MARK: - Feed
                    HStack {
                        Image(systemName: "poweron")
                            .font(.system(
                                size: 11,
                                weight: .light,
                                design: .rounded
                            ))
                            .foregroundColor(.white)
                            .opacity(offset == screenWidth * 2 ? 1 : 0)
                        
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(
                                size: 20,
                                weight: self.offset >= ((screenWidth * 2) - screenWidth * 0.5) && self.offset < ((screenWidth * 3) - screenWidth * 0.5) ? .bold : .light,
                                design: .rounded
                            ))
                            .foregroundColor(self.offset >= ((screenWidth * 2) - screenWidth * 0.5) && self.offset < ((screenWidth * 3) - screenWidth * 0.5) ? .accent : .primary)
                            .onTapGesture {
                                withAnimation {
                                    self.offset = screenWidth * 2
                                }
                            }
                        
                        Image(systemName: "poweron")
                            .font(.system(
                                size: 11,
                                weight: .light,
                                design: .rounded
                            ))
                            .foregroundColor(.white)
                            .opacity(offset == screenWidth * 2 ? 1 : 0)
                    }
                    
                    Spacer()
                    
                    //MARK: - Quizzes
                    HStack {
                        Image(systemName: "poweron")
                            .font(.system(
                                size: 11,
                                weight: .light,
                                design: .rounded
                            ))
                            .foregroundColor(.white)
                            .opacity(offset == screenWidth * 3 ? 1 : 0)

                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(
                                size: 20,
                                weight: self.offset >= ((screenWidth * 3) - screenWidth * 0.5) && self.offset < ((screenWidth * 4) - screenWidth * 0.5) ? .bold : .light,
                                design: .rounded
                            ))
                            .foregroundColor(self.offset >= ((screenWidth * 3) - screenWidth * 0.5) && self.offset < ((screenWidth * 4) - screenWidth * 0.5) ? .accent : .primary)
                            .onTapGesture {
                                withAnimation {
                                    self.offset = screenWidth * 3
                                }
                            }
                        
                        Image(systemName: "poweron")
                            .font(.system(
                                size: 11,
                                weight: .light,
                                design: .rounded
                            ))
                            .foregroundColor(.white)
                            .opacity(offset == screenWidth * 3 ? 1 : 0)
                    }
                    

                    Spacer()
                    
                    
                    //MARK: - Grades
                    HStack {
                        Image(systemName: "poweron")
                            .font(.system(
                                size: 11,
                                weight: .light,
                                design: .rounded
                            ))
                            .foregroundColor(.white)
                            .opacity(offset == screenWidth * 4 ? 1 : 0)

                        Image(systemName: "chart.dots.scatter")
                            .font(.system(
                                size: 20,
                                weight: self.offset >= ((screenWidth * 4) - screenWidth * 0.5) && self.offset < ((screenWidth * 5) - screenWidth * 0.5) ? .bold : .light,
                                design: .rounded
                            ))
                            .foregroundColor(self.offset >= ((screenWidth * 4) - screenWidth * 0.5) && self.offset < ((screenWidth * 5) - screenWidth * 0.5) ? .accent : .primary)
                            .padding(.trailing)
                            .onTapGesture {
                                withAnimation {
                                    self.offset = screenWidth * 4
                                }
                            }
                    }
                    
                }
            }
            .frame(width: screenWidth * 0.6, height: screenWidth / 8)
        }
    }
}

