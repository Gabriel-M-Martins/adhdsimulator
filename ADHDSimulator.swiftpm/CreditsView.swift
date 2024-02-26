//
//  CreditsView.swift
//  Meu App
//
//  Created by Gabriel Medeiros Martins on 20/02/24.
//

import SwiftUI

struct CreditsView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var soundManager: SoundManager
    
    @State private var imageOffset: CGFloat = 0
    private let imageScale: CGFloat = 1.3
    
    var body: some View {
        GeometryReader { reader in
            Image("SchoolHallway")
                .resizable()
                .scaledToFill()
                .scaleEffect(CGSize(width: imageScale, height: imageScale), anchor: .center)
                .ignoresSafeArea()
                .offset(x: imageOffset)
                .onAppear {
                    withAnimation(.easeInOut(duration: 10).repeatForever()) {
                        let offset = -500.0
                        
                        imageOffset = offset
                    }
                }
            
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            HStack{
                Spacer()
                
                VStack {
                    Spacer()
                    
                    Text("Credits")
                        .fontDesign(.serif)
                        .fontWeight(.heavy)
                        .font(.system(size: 75))
                        .foregroundStyle(.white)
                        .shadow(color: Color(UIColor.tintColor).opacity(0.5), radius: 6.25, y: 10)
                        .padding()
                    
                    Spacer()
                    
                    ScrollView {
                        VStack(alignment: .leading) {
                            HStack {
                                Spacer()
                                
                                VStack {
                                    Image("Eu")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: 120)
                                        .clipShape(Circle())
                                        .padding(.bottom, -20)

                                    Text("Gabriel M. Martins")
                                        .font(.largeTitle)
                                        .fontWeight(.heavy)
                                }
                                
                                Spacer()
                            }
                            .padding(.top, -24)
                            
                            HStack {
                                Text("My history: ")
                                    .font(.title)
                                    .foregroundStyle(Color.accentColor)
                            }
                            
                            Text("""
                                All throughout my academic life I was bombarded with judgemental and hurtful looks from my parents and teachers. All of them thought I had potential to be one of the top students in class, but wasn't even trying to study. But the truth is I was giving my best.
                                
                                Before every test I sat down, opened the study book and read it all and resolved questions about it. But those sessions were constantly interrupted by everything else around me. And even when there wasn't anything to distract me, my own thoughts would get in the way.
                                
                                This led me to reflect a lot about what was \"wrong\" with me and when I was diagnosticated with ADHD, everything started to click in place. I wasn't a failure, dumb or other harmful word I heard after every bad grade I got: my brain was just wired differently. Then, after a lot of research, I started adopting \"counter measures\" to help me in my day-to-day routine and it changed my life. Now I'm truly capable to get the best grades and achieve my full potential.
                                """)
                            .font(.title2)
                            .padding(.bottom)
                            
                            HStack(alignment: .top) {
                                Text("Background Images: ")
                                    .foregroundStyle(Color.accentColor)
                                
                                Text("Noraneko Games (https://noranekogames.itch.io/)")
                            }
                            .font(.title2)
                            
                            HStack(alignment: .top) {
                                Text("Character Image: ")
                                    .foregroundStyle(Color.accentColor)
                                
                                Text("Sutemo (https://ko-fi.com/sutemo)")
                            }
                            .font(.title2)
                            
                            HStack(alignment: .top) {
                                Text("Background Music: ")
                                    .font(.title2)
                                    .foregroundStyle(Color.accentColor)
                                
                                Text("jhaeka (https://joshuuu.itch.io/)")
                            }
                            .font(.title2)
                            
                            HStack(alignment: .top) {
                                Text("UI Sound Effects: ")
                                    .foregroundStyle(Color.accentColor)
                                
                                Text("Nathan Gibson (https://nathangibson.myportfolio.com)")
                            }
                            .font(.title2)
                            
                            HStack(alignment: .top) {
                                Text("ADHD Statistics:")
                                    .foregroundStyle(Color.accentColor)
                                
                                Text("https://www.goldenstepsaba.com/resources/adhd-statistics")
                            }
                            .font(.title2)
                        }
                        .padding(32)
                    }
                    .scrollIndicators(.never)
                    .background {
                        RoundedRectangle(cornerRadius: Tokens.CornerRadius)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.35), radius: 10)
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(32)
            
            HStack {
                Button {
                    soundManager.play()
                    dismiss()
                } label: {
                    Image(systemName: "arrow.backward")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.75), radius: 5)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    CreditsView()
        .environmentObject(SoundManager())
}
