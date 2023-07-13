//
//  WeeklyTopicDropDown.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-22.
//

import Foundation
import SwiftUI

struct WeeklyTopicDropDown: View {
    
    @Binding var topic: WeeklyTopic
    @State var droppedDown = false
    
    var body: some View {
        
        VStack {
            HStack {
                HStack {
                    Image(systemName: "number.square")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    Text("Unit: \(String(topic.weekNumber))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 2)
                
                Spacer()
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
                    
                    Text(topic.topicTitle)
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
                    
                    Text(topic.topicDescription)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
        }.padding(.horizontal)
        
    }
}
