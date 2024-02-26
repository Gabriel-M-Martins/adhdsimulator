//
//  File.swift
//  
//
//  Created by Gabriel Medeiros Martins on 22/02/24.
//

import Foundation

struct Dialog {
    enum Moment {
        case A1, A2, A3, A4, A5, A6, A7
        case B1, B2
        case C1, C2
        case D1, D2, D3
        case E1, E2, E3, E4, E5
        case F1
        
        case Quizz
        case Home
    }
    
    struct Option {
        let text: String
        let leadsTo: Moment
        let advancesPhase: Bool
        
        init(text: String, leadsTo: Moment, advancesPhase: Bool = false) {
            self.text = text
            self.leadsTo = leadsTo
            self.advancesPhase = advancesPhase
        }
    }
    
    let moment: Moment
    let text: String
    let options: [Option]
}
