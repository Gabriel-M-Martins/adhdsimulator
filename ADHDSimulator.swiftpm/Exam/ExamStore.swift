//
//  File.swift
//  
//
//  Created by Gabriel Medeiros Martins on 20/02/24.
//

import Foundation

class ExamStore: ObservableObject {
    let questions: [ExamQuestion]
    
    @Published private var currentQuestionIdx = 0
    var currentQuestion: ExamQuestion? {
        isFinished ? nil : questions[currentQuestionIdx]
    }
    
    var questionsAnsweredCorrectly: [Int] = []
    
    var isFinished: Bool {
        currentQuestionIdx + 1 > questions.count
    }
    
    init?() {
        guard let path = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: path),
              let questions = try? JSONDecoder().decode([ExamQuestion].self, from: data),
              questions.count > 0 else { return nil }
        
        self.questions = questions
    }
    
    @discardableResult
    func answerQuestion(_ answer: ExamAnswer.Key) -> Bool {
        guard let currentQuestion = currentQuestion else { return false }
        
        var result = false
        
        if currentQuestion.correctAnswerKey == answer {
            questionsAnsweredCorrectly.append(currentQuestionIdx)
            result = true
        }
        
        currentQuestionIdx += 1
        
        return result
    }
}
