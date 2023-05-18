//
//  SineWave.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import Foundation
import SwiftUI

struct AnimatableData: VectorArithmetic {
    
    var phase: Double
    
    var magnitudeSquared: Double {
        return phase * phase
    }
    
    init(phase: Double) {
        self.phase = phase
    }
    
    mutating func scale(by rhs: Double) {
        phase *= rhs
    }
    
    static func + (lhs: AnimatableData, rhs: AnimatableData) -> AnimatableData {
        return AnimatableData(phase: lhs.phase + rhs.phase)
    }
    
    static func - (lhs: AnimatableData, rhs: AnimatableData) -> AnimatableData {
        return AnimatableData(phase: lhs.phase - rhs.phase)
    }
    
    static var zero: AnimatableData {
        AnimatableData(phase: 0)
    }
}

struct SineWave: Shape {
    var frequency: Double
    var amplitude: Double
    var phase: AnimatableData
    
    var animatableData: AnimatableData {
        get { return phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let path = Path { p in
            let width = rect.width
            let height = rect.height
            
            let midHeight = height / 2
            
            let wavelength = width / CGFloat(frequency)
            
            p.move(to: CGPoint(x: 0, y: midHeight))
            
            for x in stride(from: 0, through: width, by: 1) {
                let relativeX = x / wavelength
                let sine = Double(midHeight) * amplitude * sin(2 * .pi * (Double(relativeX) - phase.phase))
                p.addLine(to: CGPoint(x: Double(x), y: Double(midHeight) - sine))
            }
            
            p.addLine(to: CGPoint(x: rect.width, y: rect.height))
            p.addLine(to: CGPoint(x: 0, y: rect.height))
        }
        
        return path
    }
}
