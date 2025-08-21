//
//  ButtonLabel.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/18/25.
//

import SwiftUI

struct ButtonLabel: View {
    @State var systemImage: String?
    @State var text: String
    @State var backgroundColor: Color = Color.pink.opacity(0.8)
    @State var foregroundColor: Color = Color.white
    
    var body: some View {
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
