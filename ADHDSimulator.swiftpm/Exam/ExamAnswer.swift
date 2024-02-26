//
//  File.swift
//  
//
//  Created by Gabriel Medeiros Martins on 20/02/24.
//

import Foundation

struct ExamAnswer: Codable {
    enum Key: String, Codable {
        case A, B, C, D
    }
    
    let text: String
    let key: Key
}
