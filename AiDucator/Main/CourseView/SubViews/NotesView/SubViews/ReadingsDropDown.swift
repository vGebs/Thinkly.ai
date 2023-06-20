//
//  ReadingsDropDown.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-20.
//

import Foundation
import SwiftUI

struct ReadingsDropDown: View {
    
    var readings: [Reading]
    @State var droppedDown = false
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "dot.square")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.accent)
                
                Text("Weekly Readings")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if droppedDown {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                } else {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }
            }
            .padding()
            .onTapGesture {
                withAnimation {
                    if droppedDown {
                        droppedDown = false
                    } else {
                        droppedDown = true
                    }
                }
            }
            
            if droppedDown {
                ForEach(readings) { reading in
                    HStack {
                        Image(systemName: "number.square")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.accent)
                        
                        Text("Chapter: \(reading.chapter)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical,3)
                    
                    HStack {
                        VStack {
                            HStack {
                                Image(systemName: "note.text")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.accent)
                                Text("Textbook:")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                        }

                        Text("\(reading.textbook.title)")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical,3)
                    
                    HStack {
                        
                        Image(systemName: "person")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.accent)
                            
                        Text("Author:")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("\(reading.textbook.author)")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical,3)
                    
                    Divider()
                }
            }
        }
    }
}
