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
    
    @Binding var loadingIndexes: Set<Int>
    @Binding var submittedSubUnits: Set<Int>
    
    var generateSubUnits: (() -> Void)?
    var submitUnits: (() -> Void)?
    var trashSubUnits: (() -> Void)?
    
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
                    VStack {
                        Image(systemName: "book.closed")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.accent)
                        Spacer()
                    }
                    
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
                }.fixedSize(horizontal: false, vertical: true)
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
                }.fixedSize(horizontal: false, vertical: true)
                
                if subunitsActive {
//                    Divider()
                    
                    RoundedRectangle(cornerRadius: 5)
                        .frame(height: 1)
                        .foregroundColor(.buttonPrimary)
//                        .padding(.leading, screenWidth * 0.035)
                    
                    if unit.subUnits != nil && !loadingIndexes.contains(unit.unitNumber - 1){
                        subUnitsDropDown
                        
                        HStack {
                            regenerateButton
                            if !self.submittedSubUnits.contains(unit.unitNumber - 1) {
                                submitButton
                            }
                        }.padding(.leading, screenWidth * 0.05)
                    } else {
                        if loadingIndexes.contains(unit.unitNumber - 1) {
                            LoadingView()
                        } else {
                            generateSubunitsButton
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }.padding(.horizontal)
    }
    
    var regenerateButton: some View {
        Button(action: {
            self.generateSubUnits?()
        }){
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.black)
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    Image(systemName: "terminal")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                    
                    Text("Regenerate")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }.padding()
            }
        }
    }
    
    var submitButton: some View {
        Button(action: {
            self.submitUnits?()
        }){
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.black)
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    Image(systemName: "checkmark.square")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                    
                    Text("Submit")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }.padding()
            }
        }
    }
    
    var subUnitsDropDown: some View {
        ZStack {
            VStack {
                ForEach(unit.subUnits!.indices, id: \.self) { index in
                    VStack {
                        HStack {
                            Image(systemName: "number.square")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.accent)
                            
                            Text(String(format: "%.1f", floor(unit.subUnits![index].unitNumber * 10) / 10))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                            
                            if index == 0 {
                                Button(action: {
                                    withAnimation {
                                        self.unit.subUnits = nil
                                        self.trashSubUnits?()
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.buttonPrimary)
                                }
                            }
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                        .padding(.leading, screenWidth * 0.05)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        HStack {
                            VStack {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.accent)
                                Spacer()
                            }
                            
                            Text("\(unit.subUnits![index].unitTitle)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                        }
//                        .padding(.top)
//                        .padding(.top, screenHeight * 0.02)
                        .padding(.leading, screenWidth * 0.05)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        Divider()
                            .padding(.leading, screenWidth * 0.035)
                        
                        HStack {
                            VStack {
                                Image(systemName: "note.text")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.accent)
                                Spacer()
                            }
                            
                            Text("\(unit.subUnits![index].unitDescription)")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.leading, screenWidth * 0.05)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .frame(height: 1)
                            .foregroundColor(.buttonPrimary)
                            .padding(.leading, screenWidth * 0.035)
                    }
                }
            }
        }
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
                        .foregroundColor(.buttonPrimary)
                    
                    Text("Generate Sub-Units")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }.padding()
            }
        }
    }
}
