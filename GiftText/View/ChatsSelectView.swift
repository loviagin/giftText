//
//  ChatsSelectView.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/15/25.
//

import SwiftUI

struct ChatsSelectView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var chats: [Chat]
    @Binding var selectedChat: Chat?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a chat")
                .font(.title)
                .bold()
                .padding(.horizontal, 20)
                .padding(.top, 20)
            
            Text("When you select a chat, the recipient's name will be substituted automatically")
                .padding(.horizontal, 20)
                .foregroundStyle(.gray)
            
            List {
                ForEach(chats.sorted(by: { $0.lastTime > $1.lastTime }), id:\.id) { chat in
                    Button {
                        selectedChat = chat
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .padding()
                                .foregroundStyle(.white)
                                .background(LinearGradient(colors: [.blue.opacity(0.3), .pink.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(chat.title)
                                    .font(.headline)
                                
                                if let message = chat.lastMessage {
                                    Text(message)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            Text("Select chat")
                                .padding(10)
                                .background(Color.pink.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
