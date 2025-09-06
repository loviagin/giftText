//
//  AccountView.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/21/25.
//

import SwiftUI
import SwiftData
import RevenueCat
import RevenueCatUI

struct AccountView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var viewModel: MainViewModel
    @Query private var users: [User]
    
    @FocusState private var focused: Field?
    @State private var isEditing = false
    @State private var name = ""
    @State private var showSubscription = false
    @State private var showEdit = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    userInfoView
                }
                
//                Section {
//                    Button {
//                        if !viewModel.subscribed {
//                            withAnimation {
//                                showSubscription = true
//                            }
//                        }
//                    } label: {
//                        HStack {
//                            if viewModel.subscribed {
//                                Label("You have a Gift Text Subscription", systemImage: "checkmark.circle")
//                            } else {
//                                Label("Gift Text Subscription", systemImage: "arrow.up.message")
//                            }
//                            Spacer()
//                            Image(systemName: "storefront")
//                        }
//                    }
//                }
                
                Section {
                    NavigationLink {
                        PrivacyView()
                    } label: {
                        Label("Privacy settings", systemImage: "gear")
                    }
                    
                    NavigationLink {
                        PoliciesView()
                    } label: {
                        Label("Policies", systemImage: "hand.raised.circle")
                    }
                    
                    NavigationLink {
                        AboutAppView()
                    } label: {
                        Label("About App", systemImage: "info.circle")
                    }
                }
            }
            .onAppear {
                fetchUser()
            }
            .alert("Edit Profile", isPresented: $showEdit, actions: {
                TextField("Enter your name", text: $name)
                Button("Cancel") {
                    name = viewModel.user?.name ?? ""
                    showEdit = false
                }
                Button("Save") {
                    save()
                    showEdit = false
                }
                .bold()
            })
            .sheet(isPresented: self.$showSubscription, onDismiss: {
                DispatchQueue.main.async {
                    Task {
                        viewModel.subscribed = await viewModel.checkSubscription()
                    }
                }
            }) {
                PaywallView()
            }
        }
    }
    
    func fetchUser() {
        guard let user = viewModel.user else {
            return
        }
        
        self.name = user.name ?? ""
    }
    
    func save() {
        guard let user = viewModel.user else {
            return
        }
        
        if let index = users.firstIndex(of: user) {
            users[index].name = name
        }
        
        viewModel.user?.name = name
        
        isEditing = false
    }
    
    var userInfoView: some View {
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 50)
                .foregroundStyle(.gray)
            
            if let user = viewModel.user {
                Text(user.name ?? "No name")
                    .padding(7)
                    .bold()
                    .font(.title2)
            }
            
            Spacer()
            
            Button {
                showEdit = true
            } label: {
                Image(systemName: "pencil")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
            }
        }
    }
}

#Preview {
    AccountView()
        .environmentObject(MainViewModel.mock)
}
