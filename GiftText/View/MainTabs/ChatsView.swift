//
//  ChatsView.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/15/25.
//

import SwiftUI
import SwiftData

struct ChatsView: View {
    @Environment(\.modelContext) private var context
    @Query private var chats: [Chat]
    @Query private var messages: [Message]
    
    @State private var showDeleteAlert = false
//    private var chats: [Chat] = [
//        Chat(title: "Hello", lastTime: Date())
//    ]
    
    var body: some View {
        NavigationStack {
            if chats.isEmpty {
                ContentUnavailableView("No chats yet", systemImage: "circle.slash")
            }
            List {
                ForEach(chats.sorted(by: { $0.lastTime > $1.lastTime }), id:\.id) { chat in
                    NavigationLink {
                        ChatView(chat: chat)
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
                                    Text(NSLocalizedString(message, comment: "Chats View"))
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .contextMenu {
                        Button("Delete chat", systemImage: "trash", role: .destructive) {
                            showDeleteAlert = true
                        }
                    }
                    .alert("Are you sure you want to delete this Chat?", isPresented: $showDeleteAlert) {
                        Button("Delete", role: .destructive) {
                            showDeleteAlert = false
                            deleteChat(chat: chat)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Chats")
        }
    }
    
    func deleteChat(chat: Chat) {
        for m in messages {
            if m.chatId == chat.id {
                context.delete(m)
            }
        }
        
        context.delete(chat)
    }
}

struct ChatView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: MainViewModel
    @State var chat: Chat
    
//    var messages: [Message] = [
//        Message(userId: "user", chatId: "st", text: "Hello"),
//        Message(userId: "system", chatId: "st", text: "Hello")
//    ]
    
    @Query private var messages: [Message]
    @State private var showDeleteAlert = false
    
    init(chat: Chat) {
        self._chat = State(initialValue: chat)
        
        let id = chat.id
        self._messages = Query(
            filter: #Predicate<Message> { $0.chatId == id },
            sort: [SortDescriptor(\.date)],
            animation: .easeInOut
        )
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(messages, id: \.id) { message in
                        MessageView(message: message)
                            .id(message.id)
                            .contextMenu {
                                Button("Copy text", systemImage: "document.on.document") {
                                    UIPasteboard.general.string = message.text
                                }
                                
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    deleteMessage(message)
                                }
                            }
                    }
                }
                .scrollIndicators(.never)
                .padding(.horizontal, 15)
                .onChange(of: messages.count) { _, _ in
                    // при появлении нового сообщения
                    if let last = messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    // при первом открытии
                    if let last = messages.last {
                        DispatchQueue.main.async {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            AppButton(text: NSLocalizedString("New Gift", comment: "Chat View"), systemImage: "plus.circle", backgroundColor: Color.pink.opacity(0.6)) {
                viewModel.newGift = Gift(name: chat.title, chat: chat)
                viewModel.selectedTab = .home
            }
            .padding(15)
        }
        .navigationTitle(chat.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Menu {
                    Button("Delete chat", systemImage: "trash", role: .destructive) {
                        showDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Are you sure you want to delete this Chat?", isPresented: $showDeleteAlert) {
//            Button("Cancel") {
//                showDeleteAlert = false
//            }
            Button("Delete", role: .destructive) {
                showDeleteAlert = false
                deleteChat()
            }
        }
    }
    
    func deleteMessage(_ message: Message) {
        context.delete(message)
        
        if messages.isEmpty {
            deleteChat()
        } else {
            chat.lastMessage = messages.last!.text
            chat.lastId = messages.last!.userId
            chat.lastTime = messages.last!.date
        }
    }
    
    func deleteChat() {
        for m in messages {
            context.delete(m)
        }
        
        context.delete(chat)
        dismiss()
    }
}

struct MessageView: View {
    @State var message: Message
    @State private var showFullscreen = false
    
    var body: some View {
        HStack {
            if message.userId == "user" {
                Spacer()
            }
            
            VStack(alignment: .leading) {
                if let image = message.image, let uiImage = UIImage(data: image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 300, height: 300)
                        .cornerRadius(15)
                        .padding(.bottom, 8)
                        .onTapGesture { showFullscreen = true }
                }
                
                Text(message.text)
                    .multilineTextAlignment(.leading)
                
                Text(message.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.top, 5)
            }
            .padding(10)
            .background(message.userId == "user" ? Color.blue.opacity(0.4) : Color.pink.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            if message.userId == "system" {
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showFullscreen) {
            FullscreenImageView(image: message.image) {
                showFullscreen = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatsView()
//        ChatView(chat: Chat(title: "Hello", lastTime: Date()))
            .environmentObject(MainViewModel.mock)
    }
}
