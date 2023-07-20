//
//  WeeklyTopicDropDown.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-22.
//

import Foundation
import SwiftUI

struct UnitDropDown: View {
    
    @Binding var unit: Unit
    @State var droppedDown = false
    let subunitsActive: Bool 
    
    var generateSubUnits: (() -> Void)?
    
    var body: some View {
        
        VStack {
            HStack {
                HStack {
                    Image(systemName: "number.square")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    Text("Unit: \(String(unit.unitNumber))")
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
                    
                    Text(unit.unitTitle)
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
                    
                    Text(unit.unitDescription)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                if subunitsActive {
                    Divider()
                    
                    generateSubunitsButton
                }
            }
        }.padding(.horizontal)
        
    }
    
    var generateSubunitsButton: some View {
        Button(action: {
            self.generateSubUnits?()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.black)
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    Image(systemName: "terminal")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    
                    Text("Generate Sub-Units")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
        }
    }
}
