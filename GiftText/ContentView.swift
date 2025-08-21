//
//  ContentView.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/13/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var viewModel: MainViewModel
    
    @Query private var users: [User]
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(AppTab.home)
            
            ChatsView()
                .tabItem {
                    Label("Chats", systemImage: "clock")
                }
                .tag(AppTab.history)
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person")
                }
                .tag(AppTab.account)
        }
        .onAppear {
            fetchUser()
        }
    }
    
    func fetchUser() {
        guard let newUser = viewModel.findUser(users) else {
//            users[0].name = nil
            return
        }
        
        context.insert(newUser)
    }
}

#Preview {
    ContentView()
        .environmentObject(MainViewModel.mock)
}
