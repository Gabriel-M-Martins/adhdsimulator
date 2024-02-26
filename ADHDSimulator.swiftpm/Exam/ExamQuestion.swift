//
//  File.swift
//  
//
//  Created by Gabriel Medeiros Martins on 20/02/24.
//

import Foundation

struct ExamQuestion: Codable, Equatable {
    static func == (lhs: ExamQuestion, rhs: ExamQuestion) -> Bool {
        lhs.number == rhs.number
    }
    
    let number: Int
    let text: String
    let answers: [ExamAnswer]
    let correctAnswerKey: ExamAnswer.Key
    
    static private var lastNumber: Int = 0
    
    init(text: String, answers: [ExamAnswer], correctAnswerKey: ExamAnswer.Key) {
        self.number = Self.lastNumber + 1
        Self.lastNumber += 1
        self.text = text
        self.answers = answers
        self.correctAnswerKey = correctAnswerKey
    }
}
