//
//  File.swift
//  
//
//  Created by Gabriel Medeiros Martins on 20/02/24.
//

import Foundation
import SwiftUI


struct Modifiers {
    struct DefaultButton: ViewModifier {
        var color: Binding<AnyShapeStyle>? = nil
        
        var width: CGFloat? = nil
        let font: Font
        
        func body(content: Content) -> some View {
            content
                .font(font)
                .fontWeight(.medium)
                .if(width != nil, transform: { view in
                    view
                        .frame(width: width)
                })
                .background {
                    if let color = color {
                        RoundedRectangle(cornerRadius: Tokens.CornerRadius)
                            .fill(color.wrappedValue)
                            .frame(width: width)
                            .shadow(color: .accentColor.opacity(0.5), radius: 5, y: 5)
                    } else {
                        RoundedRectangle(cornerRadius: Tokens.CornerRadius)
                            .fill(.background)
                            .frame(width: width)
                            .shadow(color: .accentColor.opacity(0.5), radius: 5, y: 5)
                    }
                }
        }   
    }
}
