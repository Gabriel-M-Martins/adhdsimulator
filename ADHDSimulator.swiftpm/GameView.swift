//
//  GameView.swift
//  Meu App
//
//  Created by Gabriel Medeiros Martins on 20/02/24.
//

import SwiftUI

enum GamePhase {
    case PreExam
    case Exam
    case PosExam
    case Home
    
    mutating func next() {
        switch self {
        case .PreExam:
            self = .Exam
        case .Exam:
            self = .PosExam
        case .PosExam:
            self = .Home
        case .Home:
            return
        }
    }
}

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var soundManager: SoundManager
    
    @State private var isPaused: Bool = false
    @State private var currentGamePhase: GamePhase = .PreExam
    
    var body: some View {
        GeometryReader { reader in
            let buttonWidth = reader.frame(in: .global).width * 0.15
            ZStack {
                VStack {
                    switch currentGamePhase {
                    case .PreExam:
                        VisualNovelView(isPaused: $isPaused, gamePhase: $currentGamePhase)
                            .transition(.push(from: .trailing))
                    case .Exam:
                        ExamView(isPaused: $isPaused, gamePhase: $currentGamePhase)
                            .transition(.push(from: .trailing))
                    case .PosExam:
                        VisualNovelView(isPaused: $isPaused, gamePhase: $currentGamePhase)
                            .transition(.push(from: .trailing))
                    default:
                        EmptyView()
                    }
                }

                VStack {
                    HStack {
                        Toggle(isOn: $isPaused, label: {
                            Text("\(Image(systemName: "pause.fill"))")
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.45), radius: 5)
                        })
                        .toggleStyle(.button)
                        .onChange(of: isPaused) {
                            if isPaused {
                                soundManager.play()
                            }
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding()
                
                PopUpView(enabled: $isPaused, width: reader.frame(in: .global).width * 0.45) {
                    Text("Paused")
                        .font(.largeTitle)
                        .fontDesign(.serif)
                
                    HStack(spacing: 40) {
                        Spacer()
                        
                        Button {
                            soundManager.play()
                            dismiss()
                        } label: {
                            Text("Exit")
                                .padding()
                                .modifier(Modifiers.DefaultButton(width: buttonWidth, font: .title3))
                        }
                        
                        Button {
                            soundManager.play()
                            isPaused = false
                        } label: {
                            Text("Continue")
                                .padding()
                                .modifier(Modifiers.DefaultButton(width: buttonWidth, font: .title3))
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .onChange(of: currentGamePhase) {
            if currentGamePhase == .Home {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        GameView()
            .environmentObject(SoundManager())
    }
}
