//
//  NotesViewModel.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-18.
//

import Foundation
import Combine

//for this class we need to fetch all of the notes for that class.
//So for the course they are in, fetch all of the notes,

class NotesViewModel: ObservableObject {
    @Published var chapters: [Chapter] = [
        Chapter(title: "Intro", notes: [
            Note(title: "Intro to this course", content: ""),
            Note(title: "Sylabus", content: "")
        ]),
        Chapter(title: "Big stuff", notes: [
            Note(title: "This is the big stuff", content: "")
        ]),
        Chapter(title: "Final notes", notes: [
            Note(title: "Final info and shit", content: "")
        ])
    ]
    
    @Published var weeklyContent: [WeeklyContent] = [
        WeeklyContent(
            notesOutline: [],
            assessments: [],
            topics: [
                Topic(readings: [
                    Reading(
                        chapter: 1,
                        textbook: Textbook(
                            title: "Designing Data-Intensive Applications: The Big Ideas Behind Reliable, Scalable, and Maintainable Systems",
                            author: "Martin Kleppmann"
                    )),
                    Reading(
                        chapter: 1,
                        textbook: Textbook(
                            title: "FUNDAMENTALS OF SOFTWARE ARCHITECTURE: AN ENGINEERING APPROACH",
                            author: "Mark Richards"
                        )),
                    Reading(
                        chapter: 1,
                        textbook: Textbook(
                            title: "Clean Architecture: A Craftsman's Guide to Software Structure and Design",
                            author: "Robert Martin"
                        ))
                     ],
                      topicName: "Introduction to Software Architecture"),
                
                Topic(readings: [
                    Reading(
                        chapter: 2,
                        textbook: Textbook(
                            title: "FUNDAMENTALS OF SOFTWARE ARCHITECTURE: AN ENGINEERING APPROACH",
                            author: "Mark Richards"
                        ))
                ],
                      topicName: "Software Requirements and Design")
            ],
            week: 1,
            classOutline: []
        )
    ]
    
    init(courseDef: CourseDefinition?) {
        //on init we need to fetch the weekly content
        //we will not store all of weeks in the same document (faster fetching)
        //Once we get the CourseDefinition,
    }
    
    func addChapter(title: String) {
        guard title != "" else { return }
        
        let chapter = Chapter(title: title, notes: [])
        self.chapters.append(chapter)
    }
}
