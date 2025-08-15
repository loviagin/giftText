//
//  FieldView.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/15/25.
//

import SwiftUI

struct FieldView<Content: View>: View {
    @FocusState.Binding var focused: Field?
    @State var focus: Field
    @State var nextFocus: Field? = nil
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 1)
                .fill(Color.app.opacity(0.4))
                .padding(.horizontal)
            
            Group {
                content()
            }
            .foregroundStyle(Color.dark)
            .bold()
            .padding(10)
            .padding(.horizontal)
            .focused($focused, equals: focus)
            .onSubmit {
                withAnimation {
                    focused = nextFocus
                }
            }
            
            if (focus == .typeEvent && focused != .typeEvent) /*|| (focus == .style && focused != .style) */{
                Image(systemName: "arrowtriangle.down.fill")
                    .foregroundStyle(.gray)
                    .padding(.trailing, 30)
            }
        }
    }
}
