//
//  PrivacyView.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/22/25.
//

import SwiftUI
import SwiftData

struct PrivacyView: View {
    @Environment(\.modelContext) private var context
    @Query private var users: [User]
    @Query private var chats: [Chat]
    
    @State private var showChatsAlert = false
    @State private var showAccountAlert = false
    @State private var showAllAlert = false
    
    var body: some View {
        Form {
            Section {
                Button("Change Language") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            } header: {
                Text("Language")
            }
            
            Section {
                Button("Delete All Chats") {
                    showChatsAlert = true
                }
                Button("Delete My Account") {
                    showAccountAlert = true
                }
                Button("Delete All Data") {
                    showAllAlert = true
                }
                .tint(.red)
            } header: {
                Text("Sensitive Data")
            }
        }
        .navigationTitle("Settings")
        .toolbar(.hidden, for: .tabBar)
        .alert("Are you sure you want to delete all of your chats?", isPresented: $showChatsAlert) {
            Button("Delete", role: .destructive) {
                deleteAllChats()
            }
        }
        .alert("Are you sure you want to delete your Account?", isPresented: $showAccountAlert) {
            Button("Delete", role: .destructive) {
                deleteMyAccount()
            }
        }
        .alert("Are you sure you want to delete all of your Data?", isPresented: $showAllAlert) {
            Button("Delete", role: .destructive) {
                deleteAllData()
            }
        }
    }
    
    func deleteAllChats() {
        chats.forEach { ch in
            context.delete(ch)
        }
    }
    
    func deleteMyAccount() {
        users.forEach { u in
            context.delete(u)
        }
    }
    
    func deleteAllData() {
        deleteAllChats()
        deleteMyAccount()
    }
}

#Preview {
    NavigationStack {
        PrivacyView()
    }
}
