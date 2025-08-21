//
//  AboutAppView.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/22/25.
//

import SwiftUI

struct AboutAppView: View {
    @EnvironmentObject private var viewModel: MainViewModel
    
    @State private var donationAllowed = false
    
    var body: some View {
        Form {
            Section {
                Text("Developer: LOVIGIN LTD")
                Link(destination: URL(string: "https://lovigin.com")!, label: { Text("Official website") })
            }
            
            Section {
                Link(destination: URL(string: "https://lovigin.com/contacts")!, label: { Text("Contact us") })
                
                if donationAllowed {
                    Link(destination: URL(string: "https://lovigin.com/donation")!, label: { Text("Donate") })
                }
            }
            
            Section {
                Text("Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
            }
        }
        .navigationTitle("About App")
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            checkDonation()
        }
    }
    
    func checkDonation() {
        Task {
            donationAllowed = await viewModel.checkDonationAllowance()
        }
    }
}

#Preview {
    NavigationStack {
        AboutAppView()
            .environmentObject(MainViewModel.mock)
    }
}
