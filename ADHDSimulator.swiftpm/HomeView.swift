//
//  HomeView.swift
//  ADHD Sim
//
//  Created by Gabriel Medeiros Martins on 19/02/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var soundManager: SoundManager
    
    @State private var imageOffset: CGFloat = 0
    private let imageScale: CGFloat = 1.3
    
    var body: some View {
        GeometryReader { reader in
            let buttonWidth = reader.frame(in: .global).width * 0.3
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
            
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    
                    Text("ADHD Simulator")
                        .fontDesign(.serif)
                        .fontWeight(.heavy)
                        .font(.system(size: 95))
                        .foregroundStyle(.white)
                        .shadow(color: Color(UIColor.tintColor).opacity(0.65), radius: 6.25, y: 10)
                        .padding()
                    
                    Spacer()
                    
                    NavigationLink {
                        GameView()
                            .onAppear {
                                soundManager.play()
                            }
                            .navigationBarBackButtonHidden()
                    } label: {
                        Text("Start")
                            .padding()
                            .modifier(Modifiers.DefaultButton(width: buttonWidth, font: .title))
                    }
                    .padding()
                    
                    NavigationLink {
                        CreditsView()
                            .navigationBarBackButtonHidden()
                            .onAppear {
                                soundManager.play()
                            }
                    } label: {
                        Text("Credits")
                            .padding()
                            .modifier(Modifiers.DefaultButton(width: buttonWidth, font: .title))
                    }
                    .padding()
                    
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(SoundManager())
    }
}
