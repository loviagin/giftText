//
//  AppButton.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/17/25.
//

import SwiftUI

struct AppButton: View {
    @State var text: String
    @State var systemImage: String?
    @State var onClickText: String?
    @State var backgroundColor: Color = Color.pink.opacity(0.8)
    @State var foregroundColor: Color = Color.white
    @State var action: () -> Void
    
    @State private var internalText = ""
    
    var body: some View {
        Button {
            if let onClickText {
                internalText = text
                self.text = onClickText
            }
            
            action()
            
            if onClickText != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.text = internalText
                }
            }
        } label: {
            HStack {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                
                Text(text)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(15)
        }
    }
}
