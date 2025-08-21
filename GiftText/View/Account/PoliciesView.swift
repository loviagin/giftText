//
//  PoliciesView.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/22/25.
//

import SwiftUI

struct PoliciesView: View {
    @State private var showPrivacy = false
    @State private var showTerms = false
    
    var body: some View {
        Form {
            Button("Privacy Policy") {
                showPrivacy.toggle()
            }
            
            Button("Terms of Use") {
                showTerms.toggle()
            }
        }
        .navigationTitle("Policies")
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showPrivacy) {
            privacyPolicyView
        }
        .sheet(isPresented: $showTerms) {
            termsView
        }
    }
    
    var termsView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Terms of Use")
                    .font(.title)
                    .bold()
                
                Text("\n\nBy using GiftText, you agree to the following terms:\n\nSubscriptions\n- GiftText offers optional Pro subscriptions.\n- Payment is charged to your Apple ID account through RevenueCat.\n- Subscriptions automatically renew unless canceled at least 24 hours before the end of the current period.\n- You can manage or cancel your subscription in your Apple ID account settings.\n\nUse of the App\n- GiftText is for personal, non-commercial use only.\n- You may not use the app for illegal or harmful purposes.\n- Generated content is the responsibility of the user.\n\nThird-Party Services\n- GiftText uses Google Gemini and Imagen to generate text and images.\n- GiftText uses RevenueCat to process and manage subscriptions.\n\nDisclaimer\n- We do not guarantee the accuracy, reliability, or appropriateness of generated content.\n- Service availability may vary and can be changed without notice.\n\nContact Us\nIf you have questions about these Terms of Use, please contact us via the company website form or email: gifttext@lovigin.com\n\nEffective Date: August 2025")
            }
            .padding()
        }
    }
    
    var privacyPolicyView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Privacy Policy")
                    .font(.title)
                    .bold()
                
                Text("\n\nGiftText respects your privacy and is committed to protecting your personal data.\n\nInformation We Collect\n- Name: collected when you create a greeting. Used only for personalization.\n- Generated gifts: text and images you create are stored in your in-app chat history.\n- Purchase information: collected through RevenueCat to manage subscriptions.\n\nThird-Party Services\n- Google Gemini and Imagen: used to generate text and image greetings.\n- RevenueCat: used for handling in-app subscriptions and purchases.\n\nData Usage\n- We do not sell or share your personal information with third parties for marketing.\n- Data is used only to provide app functionality (greeting generation, subscription access).\n\nData Storage\n- Your generated greetings are stored locally in the app chat history.\n- Subscription records are processed securely through RevenueCat.\n\nContact Us\nIf you have questions about this Privacy Policy, please contact us via the company website form or email: gifttext@lovigin.com\n\nEffective Date: August 2025")
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        PoliciesView()
    }
}
