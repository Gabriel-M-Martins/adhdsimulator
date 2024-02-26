//
//  File.swift
//
//
//  Created by Gabriel Medeiros Martins on 20/02/24.
//

import SwiftUI

struct ExamView: View {
    @EnvironmentObject var soundManager: SoundManager
    
    @Binding var isPaused: Bool
    @Binding var gamePhase: GamePhase
    
    @StateObject var store: ExamStore = ExamStore()!
    
    @State private var thoughtBubbles: [(idx: Int, text: String, position: CGPoint, scale: CGFloat, rect: CGRect, timer: Timer?)] = []
    
    @State private var spawnTimer: Timer? = nil
    @State private var spawnTimerFabric: Timer? = nil
    
    @State private var draggedBubbleIdx: Int = -1
    @State private var draggedBubbleShadowRadius: CGFloat = 1
    @State private var draggedBubbleShadowOpacity: CGFloat = 0.1
    
    @State private var currentSpawnTimeIdx = 0
    private let spawnTimes: [Double] = [
        5, 2, 0.5,
    ]
    
    @State private var currentAnimationDurationRangeIdx: Int = 0
    private let animationDurantionRanges: [ Range<Double> ] = [
        8..<12,
        4..<7,
        1.5..<3.5
    ]

    private let phaseChangeInterval: Double = 10

    private let maxBubbles: Int = 100

    @State private var shouldDisplayEndExamPopUp: Bool = false
    
    @State private var examTimeRemaining = 45
    let examTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    @State private var timerBackgroundFlashingTimer: Timer? = nil
    @State private var timerScale: CGFloat = 1
    @State private var timerBackgroundColor = Self.timerBackgroundInitialColor
    static private let timerBackgroundInitialColor = Color.white
    static private let timerBackgroundDangerColor = Color.red
    
    
    @State private var shouldDisplayCard: Bool = false
    
    @State private var currentQuestionColorIdx: Int = 0
    static private let questionsColors: [Color] = [.mint, .red, .cyan, .orange]
    
    @State private var currentQuestionTextOpacity: Double = 1
    
    @State private var answerColors: [AnyShapeStyle] = .init(repeating: Self.answerColorDefault, count: 4)
    
    @State private var correctAnswers: [ExamQuestion] = []
    
    static private let answerColorCorrect: AnyShapeStyle = .init(.green)
    static private let answerColorWrong: AnyShapeStyle = .init(.red)
    static private let answerColorDefault: AnyShapeStyle = .init(.background)
    
    private func changeQuestionColor() {
        if currentQuestionColorIdx == Self.questionsColors.count - 1 {
            currentQuestionColorIdx = 0
            return
        }
        
        withAnimation(.easeInOut) {
            currentQuestionColorIdx += 1
        }
    }
    
    private func timeSpawnerFabric(screenSize: CGSize, timeInterval: Double) -> Timer? {
        if screenSize == .zero { return nil }
        return Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { timer in
            if isPaused { return }
            
            let x = CGFloat.random(in: 0..<screenSize.width)
            let y = CGFloat.random(in: 0..<screenSize.height)
            
            withAnimation(.easeIn) {
                thoughtBubbles.append((thoughtBubbles.count, ThoughtStore.thoughts.randomElement()!, CGPoint(x: x, y: y), .random(in: 0.1..<0.4), .init(), nil))
            }
            
            if thoughtBubbles.count == maxBubbles { timer.invalidate() }
        })
    }
    
    private func displayEndExamPopUp() {
        spawnTimerFabric?.invalidate()
        spawnTimerFabric = nil
        
        for thoughtBubble in thoughtBubbles {
            thoughtBubble.timer?.invalidate()
        }
        
        withAnimation(.smooth) {
            shouldDisplayEndExamPopUp = true
        }
    }
    
    private func answerQuestion(_ answer: ExamAnswer.Key) {
        soundManager.play()
        changeQuestionColor()
        
        var answeredCorrectly = false
        var answerColorIdx = -1
        
        switch answer {
        case .A:
            answeredCorrectly = store.answerQuestion(.A)
            answerColorIdx = 0
        case .B:
            answeredCorrectly = store.answerQuestion(.B)
            answerColorIdx = 1
        case .C:
            answeredCorrectly = store.answerQuestion(.C)
            answerColorIdx = 2
        case .D:
            answeredCorrectly = store.answerQuestion(.D)
            answerColorIdx = 3
        }
        
        if let question = store.currentQuestion, answeredCorrectly {
            correctAnswers.append(question)
        }
        
        var loopCount = 0
        let duration = 0.15
        withAnimation(.snappy(duration: duration)) {
            answerColors[answerColorIdx] = answeredCorrectly ? Self.answerColorCorrect : Self.answerColorWrong
        } completion: {
            withAnimation(.snappy(duration: duration)) {
                answerColors[answerColorIdx] = Self.answerColorDefault
            } completion: {
                withAnimation(.snappy(duration: duration)) {
                    answerColors[answerColorIdx] = answeredCorrectly ? Self.answerColorCorrect : Self.answerColorWrong
                } completion: {
                    withAnimation(.snappy(duration: duration)) {
                        answerColors[answerColorIdx] = Self.answerColorDefault
                    }
                }
            }
        }
        
//        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
//            if loopCount == 4 {
//                timer.invalidate()
//                return
//            }
//            
//            withAnimation(.snappy(duration: 0.175)) {
//                answerColors[answerColorIdx] = answeredCorrectly ? Self.answerColorCorrect : Self.answerColorWrong
//            } completion: {
//                withAnimation(.snappy) {
//                    answerColors[answerColorIdx] = Self.answerColorDefault
//                }
//            }
//            
//            loopCount += 1
//        }
//        .fire()
    }
    
    var body: some View {
        GeometryReader { reader in
            let screenSize: CGSize = reader.frame(in: .global).size
            let buttonWidth: CGFloat = screenSize.width * 0.2
            
            let currentQuestion: ExamQuestion = store.currentQuestion ?? store.questions.last!
            
            let backgroundImageScale: CGFloat = screenSize.width > screenSize.height ? 2.2 : 3
            VStack {
                Spacer()
                
                Image("Classroom")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(CGSize(width: backgroundImageScale, height: backgroundImageScale), anchor: .center)
                    .ignoresSafeArea()
                    .animation(.easeInOut, value: backgroundImageScale)
                    .onAppear {
                        spawnTimerFabric = Timer.scheduledTimer(withTimeInterval: phaseChangeInterval, repeats: true, block: { timer in
                            if isPaused || shouldDisplayEndExamPopUp { return }
                            
                            if currentAnimationDurationRangeIdx + 1 < animationDurantionRanges.count {
                                currentAnimationDurationRangeIdx += 1
                            }
                            
                            if currentSpawnTimeIdx + 1 > spawnTimes.count {
                                timer.invalidate()
                                return
                            }
                            
                            spawnTimer?.invalidate()
                            
                            spawnTimer = timeSpawnerFabric(screenSize: reader.size, timeInterval: spawnTimes[currentSpawnTimeIdx])
                            spawnTimer?.fire()
                            
                            currentSpawnTimeIdx += 1
                        })
                        
                        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
                            withAnimation(.spring) {
                                shouldDisplayCard = true
                            }
                        }
                        
                        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
                            spawnTimerFabric?.fire()
                        }
                    }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                // MARK: - Timer
                let (minutes, seconds) = examTimeRemaining.quotientAndRemainder(dividingBy: 60)
                RoundedRectangle(cornerRadius: Tokens.CornerRadius)
                    .fill(timerBackgroundColor)
                    .overlay {
                        Text("\(minutes < 10 ? "0" : "")\(minutes):\((seconds < 10 && seconds != 0) ? "0" : "")\(seconds)\(seconds == 0 ? "0" : "")")
                            .font(.largeTitle)
                            .onReceive(examTimer) { _ in
                                if !isPaused && examTimeRemaining > 0 && shouldDisplayCard {
                                    examTimeRemaining -= 1
                                }
                            }
                            .padding()
                    }
                    .frame(width: screenSize.width * 0.25, height: screenSize.height * 0.05)
                    .padding()
                    .scaleEffect(x: timerScale, y: timerScale, anchor: .center)
                    .scaleEffect(x: shouldDisplayCard ? 1 : 0, y: shouldDisplayCard ? 1 : 0, anchor: .center)
                    .shadow(color: .black.opacity(0.35), radius: 10)
                    .onChange(of: examTimeRemaining) {
                        if examTimeRemaining == 0 { return }
                        
                        if examTimeRemaining == 10 && timerBackgroundFlashingTimer == nil {
                            timerBackgroundFlashingTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
                                if examTimeRemaining <= 5 {
                                    timer.invalidate()
                                    timerBackgroundFlashingTimer = nil
                                }
                                
                                let color = timerBackgroundColor == Self.timerBackgroundInitialColor ? Self.timerBackgroundDangerColor : Self.timerBackgroundInitialColor
                                
                                withAnimation(.snappy) {
                                    timerBackgroundColor = color
                                }
                                
                                withAnimation(.bouncy(duration: 0.5)) {
                                    timerScale = timerScale == 1.1 ? 0.90909 : 1.1
                                }
                            })
                            
                            timerBackgroundFlashingTimer?.fire()
                        }
                        
                        if examTimeRemaining == 5 {
                            timerBackgroundFlashingTimer?.invalidate()
                            
                            timerBackgroundFlashingTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: { timer in
                                let color = timerBackgroundColor == Self.timerBackgroundInitialColor ? Self.timerBackgroundDangerColor : Self.timerBackgroundInitialColor
                                
                                withAnimation(.snappy) {
                                    timerBackgroundColor = color
                                }
                                
                                withAnimation(.bouncy(duration: 0.25)) {
                                    timerScale = timerScale == 1.1 ? 0.90909 : 1.1
                                }
                                
                                if examTimeRemaining == 0 {
                                    timer.invalidate()
                                    timerBackgroundFlashingTimer = nil
                                    
                                    withAnimation(.snappy) {
                                        timerBackgroundColor = Self.timerBackgroundDangerColor
                                    }
                                    
                                    return
                                }
                            })
                            
                            timerBackgroundFlashingTimer?.fire()
                        }
                    }
                
                // MARK: - Question Card
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(currentQuestion.number).")
                                .bold()
                            
                            Text("\(currentQuestion.text)")
                        }
                        .font(.title)
//                        .padding()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(currentQuestion.answers, id:\.key) { answer in
                                Text("\(answer.key.rawValue)) \(answer.text)")
                                    .font(.title2)
                            }
                        }
//                        .padding()
                    }
                    .padding()
                }
                .padding()
                .scaleEffect(x: shouldDisplayCard ? 1 : 0, y: shouldDisplayCard ? 1 : 0, anchor: .center)
                .frame(maxWidth: screenSize.width * 0.9)
                .animation(.none, value: gamePhase)
                .animation(.easeInOut, value: currentQuestion)
                .opacity(currentQuestionTextOpacity)
                .onChange(of: currentQuestion) {
                    withAnimation(.linear(duration: 0.001)) {
                        currentQuestionTextOpacity = 0
                    } completion: {
                        withAnimation(.linear.delay(0.1)) {
                            currentQuestionTextOpacity = 1
                        }
                    }
                }
                .background {
                    ZStack {
                        let cornerDistance: CGFloat = 8
                        
                        RoundedRectangle(cornerRadius: Tokens.CornerRadius + cornerDistance)
                            .fill(Self.questionsColors[currentQuestionColorIdx])
                            .shadow(color: .black.opacity(0.35), radius: 10)
                        
                        RoundedRectangle(cornerRadius: Tokens.CornerRadius)
                            .fill(Color(uiColor: UIColor.systemBackground))
                            .padding(cornerDistance)
                    }
                    .scaleEffect(x: shouldDisplayCard ? 1 : 0, y: shouldDisplayCard ? 1 : 0, anchor: .center)
                }
                
                Spacer()
                
                // MARK: - Bottom Sheet
                VStack(spacing: 20) {
                    let title: AttributedString = {
                        var result = AttributedString("What is the answer to the ")
                        
                        var hightlight = AttributedString("question \(currentQuestion.number)")
                        hightlight.foregroundColor = Self.questionsColors[currentQuestionColorIdx]
                        
                        result.append(hightlight)
                        result.append(AttributedString("?"))
                        
                        return result
                    }()
                    
                    Text(title)
                        .font(.largeTitle)
                        .padding(.top)
                        .animation(.easeInOut, value: title)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            Button {
                                answerQuestion(.A)
                            } label: {
                                Text("Answer A")
                                    .padding()
                                    .modifier(Modifiers.DefaultButton(color: $answerColors[0], width: buttonWidth, font: .title))
                            }
                            
                            Button {
                                answerQuestion(.B)
                            } label: {
                                Text("Answer B")
                                    .padding()
                                    .modifier(Modifiers.DefaultButton(color: $answerColors[1], width: buttonWidth, font: .title))
                            }
                        }
                        
                        HStack(spacing: 20) {
                            Button {
                                answerQuestion(.C)
                            } label: {
                                Text("Answer C")
                                    .padding()
                                    .modifier(Modifiers.DefaultButton(color: $answerColors[2], width: buttonWidth, font: .title))
                            }
                            
                            Button {
                                answerQuestion(.D)
                            } label: {
                                Text("Answer D")
                                    .padding()
                                    .modifier(Modifiers.DefaultButton(color: $answerColors[3], width: buttonWidth, font: .title))
                            }
                        }
                        
                        Divider()
                            .padding(.horizontal)
                    }
                    
                }
                .padding()
                .disabled(store.isFinished)
                .animation(.spring, value: store.isFinished)
                .background {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .clipShape(
                            .rect(
                                topLeadingRadius: Tokens.CornerRadius,
                                topTrailingRadius: Tokens.CornerRadius
                            )
                        )
                        .shadow(color: .black.opacity(0.35), radius: 10)
                }
            }
            
            ForEach(thoughtBubbles, id:\.idx) { (idx, text, position, scale, size, _) in
                VStack {
                    Text(text)
                        .frame(maxWidth: screenSize.width < screenSize.height ? screenSize.width * 0.24 : screenSize.height * 0.24)
                        .multilineTextAlignment(.center)
                        .padding(32)
                        .font(.title3)
                        .background {
                            Image("Cloud")
                                .resizable()
                                .imageScale(.small)
                                .shadow(color: .black.opacity(0.6), radius: 5)
                        }
                }
                .onAppear {
                    let animationDuration = Double.random(in: animationDurantionRanges[currentAnimationDurationRangeIdx])
                    
                    thoughtBubbles[idx].timer = Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true, block: { _ in
                        if isPaused || shouldDisplayEndExamPopUp { return }
                        let x = CGFloat.random(in: 0..<reader.size.width)
                        let y = CGFloat.random(in: 0..<reader.size.height)
                        
                        let newScale = thoughtBubbles[idx].scale > 2 ? thoughtBubbles[idx].scale : thoughtBubbles[idx].scale + ((thoughtBubbles[idx].scale + .random(in: 0..<10)) * CGFloat.random(in: 0.0075..<0.035))
                        
                        withAnimation(.smooth(duration: animationDuration + ((animationDuration + .random(in: 0..<10)) * 0.75))) {
                            thoughtBubbles[idx].position = CGPoint(x: x, y: y)
                        }
                        
                        withAnimation(.spring) {
                            thoughtBubbles[idx].scale = newScale
                        }
                        
                        withAnimation(.easeInOut(duration: .random(in: 0.1..<0.3)).repeatForever()) {
                            thoughtBubbles[idx].scale += 0.01
                        }
                    })
                    
                    thoughtBubbles[idx].timer?.fire()
                }
                .onDisappear {
                    thoughtBubbles[idx].timer?.invalidate()
                }
                .scaleEffect(x: scale, y: scale)
                .position(position)
                .zIndex(draggedBubbleIdx == idx ? 5 : 0)
                .shadow(color: draggedBubbleIdx == idx ? .accentColor.opacity(draggedBubbleShadowOpacity) : .clear, radius: draggedBubbleShadowRadius)
                .gesture(
                    DragGesture()
                        .onChanged({ gesture in
                            withAnimation(.bouncy) {
                                thoughtBubbles[idx].position = gesture.location
                                thoughtBubbles[idx].scale += 0.001
                            }
                            
                            withAnimation(.bouncy) {
                                draggedBubbleIdx = idx
                                
                                draggedBubbleShadowRadius = draggedBubbleShadowRadius > 5 ? draggedBubbleShadowRadius : draggedBubbleShadowRadius + 0.1
                                
                                draggedBubbleShadowOpacity = draggedBubbleShadowOpacity > 1 ? 1 : draggedBubbleShadowOpacity + 0.075
                            }
                        })
                        .onEnded({ _ in
                            withAnimation(.bouncy) {
                                draggedBubbleIdx = -1
                                draggedBubbleShadowRadius = 1
                                draggedBubbleShadowOpacity = 0.1
                                thoughtBubbles[idx].scale *= 0.35
                            }
                            
                            thoughtBubbles[idx].timer?.fire()
                        })
                )
            }
            
            PopUpView(enabled: $shouldDisplayEndExamPopUp) {
                VStack {
                    let popupButtonWidth = screenSize.width * 0.65
                    
                    Text("Times up!")
                        .font(.largeTitle)
                        .padding()
                    
                    let text: AttributedString = {
                        var finalText = AttributedString("You answered ")
                        
                        var highlight1 = AttributedString(" \(correctAnswers.count) ")
                        highlight1.foregroundColor = .white
                        highlight1.backgroundColor = Color(UIColor.tintColor).opacity(0.6)
                        highlight1.font = highlight1.font?.bold()
                        finalText.append(highlight1)
                        
                        finalText.append(AttributedString(" questions correctly out of the "))
                        
                        var highlight2 = AttributedString(" \(store.currentQuestion?.number ?? store.questions.last!.number) ")
                        highlight2.foregroundColor = .white
                        highlight2.backgroundColor = Color(UIColor.tintColor).opacity(0.6)
                        highlight2.font = highlight1.font?.bold()
                        
                        
                        finalText.append(highlight2)
                        
                        finalText.append(AttributedString("! That's a lot! \nCongratulations!\n\nShall we continue our talk?"))
                        
                        return finalText
                    }()
                    
                    Text(text)
                        .font(.title)
                        .frame(width: popupButtonWidth)
                    
                    VStack(spacing: 20) {
                        Button {
                            soundManager.play()
                            withAnimation {
                                withAnimation(.smooth) {
                                    gamePhase.next()
                                }
                            }
                        } label: {
                            Text("Yes!")
                                .padding()
                                .modifier(Modifiers.DefaultButton(width: popupButtonWidth, font: .title))
                        }
                        .padding()
                        
                        Button {
                            soundManager.play()
                            withAnimation {
                                withAnimation(.smooth) {
                                    gamePhase = .Home
                                }
                            }
                        } label: {
                            Text("No, I'm good. Thanks.")
                                .padding()
                                .modifier(Modifiers.DefaultButton(width: popupButtonWidth, font: .title))
                        }
                        .padding()
                    }
                    .padding()
                }
                .padding()
            }
        }
        .onDisappear {
            spawnTimerFabric?.invalidate()
        }
        .onChange(of: store.isFinished) {
            displayEndExamPopUp()
        }
        .onChange(of: examTimeRemaining) {
            if examTimeRemaining == 0 {
                displayEndExamPopUp()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ExamView(isPaused: .constant(false), gamePhase: .constant(.Exam))
        .environmentObject(SoundManager())
}
