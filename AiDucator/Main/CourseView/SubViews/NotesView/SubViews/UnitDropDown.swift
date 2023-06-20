//
//  UnitDropDown.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-18.
//

import Foundation
import SwiftUI

struct MyUnitsDropDown: View {
    @State var expandedTopic: String? = nil
    var thisWeeksContent: WeeklyContent
    
    var body: some View {
        VStack {
            HStack {
                Text("Week: \(thisWeeksContent.week)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }.padding(.leading)
            
            
            
            ForEach(thisWeeksContent.topics) { topic in
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.black)
                    RoundedRectangle(cornerRadius: 15)
                        .stroke()
                        .foregroundColor(.accent)
                    
                    VStack {
                        
                        HStack {
                            Image(systemName: "newspaper")
                                .foregroundColor(.buttonPrimary)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .padding(.horizontal)
                            
                            Text(topic.topicName)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: expandedTopic == topic.topicName ? "chevron.up" : "chevron.down")
                                .foregroundColor(.buttonPrimary)
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .padding(.trailing)
                        }
                        .padding(.vertical)
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.2)) {
                                if expandedTopic == topic.topicName {
                                    expandedTopic = nil
                                } else {
                                    expandedTopic = topic.topicName
                                }
                            }
                        }
                        
                        if expandedTopic == topic.topicName {
                            Divider()
                            if topic.readings.count > 0 {
                                ReadingsDropDown(readings: topic.readings)
                            } else {
                                //regenerate readings
                            }
                            
                            if thisWeeksContent.assessments.count > 0 {
                                HStack {
                                    Image(systemName: "dot.square")
                                        .font(.system(size: 12, weight: .regular, design: .rounded))
                                        .foregroundColor(.accent)
                                    
                                    Text("Weekly Assessments")
                                        .font(.system(size: 18, weight: .regular, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 15, weight: .regular, design: .rounded))
                                        .foregroundColor(.buttonPrimary)
                                }
                                .padding()
                            } else {
                                //add a button to generate an assessment
                            }
                        }
                    }
                }
            }
        }
    }
}

