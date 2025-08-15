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
            
            HomeView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
            
            HomeView()
                .tabItem {
                    Label("Account", systemImage: "person")
                }
        }
        .onAppear {
            fetchUser()
        }
    }
    
    func fetchUser() {
        guard let newUser = viewModel.findUser(users) else {
            return
        }
        
        context.insert(newUser)
    }
}

#Preview {
    ContentView()
        .environmentObject(MainViewModel.mock)
}
