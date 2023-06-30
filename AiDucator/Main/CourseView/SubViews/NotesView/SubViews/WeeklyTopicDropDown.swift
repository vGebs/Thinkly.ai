//
//  WeeklyTopicDropDown.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-22.
//

import Foundation
import SwiftUI

struct WeeklyTopicDropDown: View {
    
    @Binding var topic: WeeklyTopicLocked
    @State var droppedDown = false
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.black)
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 3)
                .foregroundColor(.buttonPrimary)
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "number.square")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.accent)
                        Text("Unit: \(String(topic.weeklyTopic.weekNumber))")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }.padding(2).background(RoundedRectangle(cornerRadius: 5).foregroundColor(.black))
                    
                    Spacer()
                    
                    
                    Button(action: {
                        topic.lockedin.toggle()
                    }) {
                        
                        Text(topic.lockedin ? "Unlock Unit" : "Lock in Unit")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.buttonPrimary)
                        
                        Image(systemName: topic.lockedin ? "lock" : "lock.open")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.accent)
                    }.padding(2).background(RoundedRectangle(cornerRadius: 5).foregroundColor(.black))
                }
                
                Button(action: {
                    if !droppedDown {
                        withAnimation {
                            droppedDown = true
                        }
                    } else {
                        withAnimation {
                            droppedDown = false
                        }
                    }
                }) {
                    HStack {
                        
                        Image(systemName: "book.closed")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.accent)
                            
                        Text(topic.weeklyTopic.topicTitle)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if !droppedDown {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.buttonPrimary)
                        } else {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.buttonPrimary)
                        }
                    }
                }.padding(.bottom,3)
                
                if droppedDown {
                    Divider()
                    HStack {
                        VStack {
                            Image(systemName: "note.text")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.accent)
                            Spacer()
                        }
                        
                        Text(topic.weeklyTopic.topicDescription)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
            }.padding()
        }.padding(.horizontal)
    }
}
