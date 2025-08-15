//
//  GiftTextApp.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/13/25.
//

import SwiftUI
import SwiftData

@main
struct GiftTextApp: App {
    @StateObject private var mainViewModel = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mainViewModel)
                .modelContainer(for: [
                    User.self,
                    Chat.self,
                    Message.self
                ])
        }
    }
}
