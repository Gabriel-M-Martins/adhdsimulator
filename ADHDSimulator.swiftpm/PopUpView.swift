//
//  PopUpView.swift
//  ADHDSimulator
//
//  Created by Gabriel Medeiros Martins on 23/02/24.
//

import SwiftUI

struct PopUpView<Content>: View where Content: View {
    @Binding var enabled: Bool
    
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                if enabled {
                    HStack {
                        VStack {
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .background(.ultraThinMaterial)
                }
            }
            .transition(.scale)
            .animation(.bouncy, value: enabled)
            
            VStack {
                if enabled {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            content()
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: Tokens.CornerRadius)
                                .fill(.regularMaterial)
                                .shadow(color: .black.opacity(0.35), radius: 10)
                                .if(width != nil, transform: { view in
                                    view
                                        .frame(width: width)
                                })
                                .if(height != nil, transform: { view in
                                    view
                                        .frame(height: height)
                                })
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .transition(.scale)
            .animation(.bouncy, value: enabled)
        }
    }
}

#Preview {
    PopUpView(enabled: .constant(true), width: 200) {
        Text("coe")
    }
}
