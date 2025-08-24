//
//  GiftBoxLoadingView.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/20/25.
//

import SwiftUI

struct GiftBoxLoadingView: View {
    @State private var bounce = false
    @State private var shine = false
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            // Мягкая «аура»
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 180, height: 180)
                .scaleEffect(pulse ? 1.06 : 0.94)
                .opacity(0.6)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
            
            // Коробка
            VStack(spacing: 0) {
                // Крышка
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.pink.opacity(0.85))
                    .frame(width: 140, height: 26)
                    .offset(y: bounce ? -8 : 0) // лёгкий «подпрыг»
                    .animation(.interpolatingSpring(stiffness: 140, damping: 10).repeatForever(autoreverses: true), value: bounce)
                    .overlay(
                        // Бант
                        HStack(spacing: 6) {
                            Circle().fill(.white.opacity(0.6)).frame(width: 10, height: 10)
                            Circle().fill(.white.opacity(0.6)).frame(width: 10, height: 10)
                        }
                        .offset(y: -10)
                    )
                
                // Коробка (основание)
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.pink.opacity(0.6))
                    .frame(width: 140, height: 100)
                    .overlay(
                        // Ленты в тон
                        VStack(spacing: 0) {
                            Rectangle().fill(Color.white.opacity(0.25)).frame(width: 16)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 10)
                    )
            }
            .shadow(color: .pink.opacity(0.25), radius: 16, x: 0, y: 8)
            
            // Блики
            ForEach(0..<6, id: \.self) { i in
                Sparkle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(.white.opacity(0.8))
                    .offset(x: cos(CGFloat(i) * .pi/3) * 90,
                            y: sin(CGFloat(i) * .pi/3) * 90)
                    .rotationEffect(.degrees(shine ? 360 : 0))
                    .animation(.linear(duration: 2.6).repeatForever(autoreverses: false), value: shine)
                    .opacity(0.9)
            }
        }
        .onAppear {
            bounce = true
            shine = true
            pulse = true
        }
        .accessibilityLabel("Generating gift")
    }
}

/// Маленькая «звёздочка»-блик
fileprivate struct Sparkle: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2).frame(width: 2, height: 8)
            RoundedRectangle(cornerRadius: 2).frame(width: 8, height: 2)
        }
        .opacity(0.9)
    }
}

#Preview {
    GiftBoxLoadingView()
        .frame(width: 240, height: 240)
//        .background(Color(white: 0.98))
}
