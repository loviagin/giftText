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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                userInfoView
                
                Button {
                    if !viewModel.subscribed {
                        withAnimation {
                            showSubscription = true
                        }
                    }
                } label: {
                    HStack {
                        if viewModel.subscribed {
                            Label("You have a Gift Text Subscription", systemImage: "checkmark.circle")
                        } else {
                            Label("Gift Text Subscription", systemImage: "arrow.up.message")
                        }
                        Spacer()
                        Image(systemName: "storefront")
                    }
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 15) {
                    NavigationLink {
                        PrivacyView()
                    } label: {
                        HStack {
                            Label("Privacy settings", systemImage: "gear")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }

                    Divider()
                    
                    NavigationLink {
                        PoliciesView()
                    } label: {
                        HStack {
                            Label("Policies", systemImage: "hand.raised.circle")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    
                    Divider()
                    
                    NavigationLink {
                        AboutAppView()
                    } label: {
                        HStack {
                            Label("About App", systemImage: "info.circle")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .padding()
                .foregroundStyle(.dark)
            }
            .onAppear {
                fetchUser()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Edit") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                }
                
                if isEditing {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            save()
                        }
                    }
                }
            }
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
        VStack {
            Image(systemName: "person.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 50)
                .foregroundStyle(.gray)
            
            if let user = viewModel.user {
                Group {
                    if isEditing {
                        FieldView(focused: $focused, focus: .name) {
                            TextField("Enter your name", text: $name)
                        }
                    } else {
                        Text(user.name ?? "No name")
                    }
                }
                .padding(7)
                .bold()
                .font(.title2)
            }
        }
    }
}

#Preview {
    AccountView()
        .environmentObject(MainViewModel.mock)
}
