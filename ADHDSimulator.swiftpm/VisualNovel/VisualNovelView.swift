//
//  SwiftUIView.swift
//
//
//  Created by Gabriel Medeiros Martins on 22/02/24.
//

import SwiftUI

struct VisualNovelView: View {
    @EnvironmentObject var soundManager: SoundManager
    
    @Binding var isPaused: Bool
    @Binding var gamePhase: GamePhase
    
    @StateObject private var store: DialogStore = DialogStore()
    
    @State private var isFastForwarding: Bool = false
    
    @State private var currentMoment: Dialog.Moment = .A1
    private var currentDialog: Dialog {
        store.dialogs.first(where: { $0.moment == currentMoment }) ?? Dialog(moment: .A1, text: "‎", options: [])
    }
    
    @State private var currentDialogText: String = ""
    @State private var currentDialogTextIdx: String.Index? = nil
    @State private var textTimer: Timer? = nil
    @State private var textSpeed: Double = Self.initialTextSpeed
    
    static private let initialTextSpeed: Double = 0.0175
    static private let fastForwardingTextSpeed: Double = 0.005
    
    private var finishedWritingText: Bool {
        currentDialogText == currentDialog.text
    }
    
    private func writeText(reset: Bool = true) {
        textTimer?.invalidate()
        
        if reset {
            withAnimation {
                currentDialogText = ""
            }
            
            currentDialogTextIdx = nil
        }
        
        if currentDialog.text.isEmpty { return }
        
        textTimer = Timer.scheduledTimer(withTimeInterval: textSpeed, repeats: true) { timer in
            if isPaused {
                return
            }
            
            if finishedWritingText || currentDialog.text.isEmpty || currentDialogTextIdx == currentDialog.text.endIndex {
                timer.invalidate()
                currentDialogTextIdx = nil
                return
            }
            
            let idx: String.Index = currentDialogTextIdx ?? currentDialog.text.startIndex
            let nextIdx = currentDialog.text.index(after: idx)
            
            withAnimation(.linear(duration: textSpeed * 0.75)) {
                currentDialogText += currentDialog.text[idx..<nextIdx]
            }
            
            currentDialogTextIdx = nextIdx
        }
    }
    
    var body: some View {
        GeometryReader { reader in
            let screenSize: CGSize = reader.frame(in: .global).size
            let buttonWidth = screenSize.width * 0.65
            
            // MARK: Background Image
            let backgroundImageScale: CGFloat = reader.size.width > reader.size.height ? 2.2 : 3
            VStack {
                Spacer()
                
                Image("Classroom")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(CGSize(width: backgroundImageScale, height: backgroundImageScale), anchor: .center)
                    .ignoresSafeArea()
                    .animation(.easeInOut, value: backgroundImageScale)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                // MARK: Char Image
                HStack {
                    Spacer()
                    
                    Image("MaleHappy1")
                        .resizable()
                        .scaledToFit()
                }
//                HStack {
//                    Spacer()
//                    
//                    Rectangle()
//                        .frame(width: screenSize.width * 0.45, height: screenSize.height * 0.45)
//                        .padding(.trailing, 30)
//                }
                
                // MARK: Answer Area
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: reader.frame(in: .global).height * 0.45)
                    .clipShape(
                        .rect(
                            topLeadingRadius: Tokens.CornerRadius,
                            topTrailingRadius: Tokens.CornerRadius
                        )
                    )
                    .shadow(color: .black.opacity(0.35), radius: 10)
                    .overlay {
                        VStack {
                            HStack(alignment: .firstTextBaseline) {
                                Text(currentDialogText)
                                    .font(.title)
                                    .onAppear {
                                        Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { _ in
                                            writeText()
                                        }
                                    }
                                    .onChange(of: currentMoment) {
                                        if currentMoment != .C1 {
                                            writeText()
                                        }
                                    }
                                    .onChange(of: isFastForwarding) {
                                        textSpeed = isFastForwarding ? Self.fastForwardingTextSpeed : Self.initialTextSpeed
                                        
                                        if !finishedWritingText {
                                            writeText(reset: false)
                                        }
                                    }
                                
                                Spacer()
                                
                                Toggle(isOn: $isFastForwarding, label: {
                                    Text("\(Image(systemName: "bolt.fill"))")
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                        .shadow(color: .black.opacity(0.45), radius: 5)
                                        .onChange(of: isFastForwarding) {
                                            if isFastForwarding {
                                                soundManager.play()
                                            }
                                        }
                                })
                                .toggleStyle(.button)
                            }
                            .padding(.horizontal)
                            
                            Divider()
                                .frame(width: finishedWritingText ? .infinity : 0)
                                .animation(.spring, value: finishedWritingText)
                            
                            Spacer()
                            
                            VStack {
                                Spacer()
                                
                                if !currentDialog.options.isEmpty {
                                    ForEach(0..<currentDialog.options.count, id: \.self) { idx in
                                        let option = currentDialog.options[idx]
                                        let delay: Double = (Double(idx) * 0.125) + 0.35
                                        let fadeOutMultiplier: Double = (finishedWritingText ? 1.0 : 0.1)
                                        let fastForwardMultiplier: Double = (isFastForwarding ? 0.5 : 1)
                                        
                                        VStack {
                                            if finishedWritingText {
                                                Button {
                                                    soundManager.play()
                                                    if option.leadsTo == .Quizz {
                                                        withAnimation(.smooth) {
                                                            gamePhase.next()
                                                        }
                                                        return
                                                    }
                                                    
                                                    if option.leadsTo == .Home {
                                                        withAnimation(.smooth) {
                                                            gamePhase = .Home
                                                        }
                                                    }
                                                    
                                                    currentMoment = option.leadsTo
                                                } label: {
                                                    Text(option.text)
                                                        .padding()
                                                        .modifier(Modifiers.DefaultButton(width: buttonWidth, font: .title))
                                                }
                                            }
                                        }
                                        .animation(.spring(duration: (delay * fadeOutMultiplier * fastForwardMultiplier)).delay((delay * fadeOutMultiplier * fastForwardMultiplier)), value: finishedWritingText)
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding()
                    }
            }
        }
        .onAppear {
            if gamePhase == .PosExam {
                currentMoment = .C1
            }
            
            store.setPhase(gamePhase)
        }
        .background(.gray)
        .ignoresSafeArea()
    }
}

#Preview {
    VisualNovelView(isPaused: .constant(false), gamePhase: .constant(.PosExam))
        .environmentObject(SoundManager())
}
