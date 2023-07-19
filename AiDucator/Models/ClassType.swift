//
//  ClassType.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-07-19.
//

import Foundation
struct ClassType: Identifiable, Hashable {
    let id: String
    let sfSymbol: String
}

let classTypes: [ClassType] = [
    ClassType(id: "Computer Science", sfSymbol: "desktopcomputer"),
    ClassType(id: "Math", sfSymbol: "percent"),
    ClassType(id: "English Literature", sfSymbol: "book"),
    ClassType(id: "Biology", sfSymbol: "leaf.arrow.triangle.circlepath"),
    ClassType(id: "Physical Education", sfSymbol: "figure.walk"),
    ClassType(id: "History", sfSymbol: "clock"),
    ClassType(id: "Geography", sfSymbol: "globe"),
    ClassType(id: "Art", sfSymbol: "paintbrush"),
    ClassType(id: "Music", sfSymbol: "music.note"),
    ClassType(id: "Physics", sfSymbol: "atom"),
    ClassType(id: "Astronomy", sfSymbol: "staroflife"),
    ClassType(id: "Environmental Science", sfSymbol: "tree"),
    ClassType(id: "Economics", sfSymbol: "chart.bar"),
    ClassType(id: "Sociology", sfSymbol: "person.2"),
    ClassType(id: "Languages", sfSymbol: "bubble.left.and.bubble.right"),
    ClassType(id: "Philosophy", sfSymbol: "lightbulb"),
    ClassType(id: "Health Education", sfSymbol: "heart"),
    ClassType(id: "Culinary Arts", sfSymbol: "fork.knife"),
    ClassType(id: "Political Science", sfSymbol: "building.2"),
    ClassType(id: "Psychology", sfSymbol: "brain"),
    ClassType(id: "Journalism", sfSymbol: "newspaper"),
    ClassType(id: "Business Studies", sfSymbol: "briefcase"),
    ClassType(id: "Engineering", sfSymbol: "gear"),
    ClassType(id: "Architecture", sfSymbol: "building.columns"),
    ClassType(id: "Photography", sfSymbol: "camera"),
    ClassType(id: "Design", sfSymbol: "pencil.tip.crop.circle"),
    ClassType(id: "Film Studies", sfSymbol: "film"),
    ClassType(id: "Religious Studies", sfSymbol: "book.closed"),
    ClassType(id: "Marine Biology", sfSymbol: "tortoise"),
    ClassType(id: "Anthropology", sfSymbol: "archivebox"),
    ClassType(id: "Meteorology", sfSymbol: "cloud.sun"),
    ClassType(id: "Geology", sfSymbol: "globe"),
    ClassType(id: "Forestry", sfSymbol: "leaf"),
    ClassType(id: "Veterinary Studies", sfSymbol: "bandage"),
    ClassType(id: "Robotics", sfSymbol: "gearshape.2"),
    ClassType(id: "Nursing", sfSymbol: "cross.case")
]
