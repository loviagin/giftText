//
//  GiftTextApp.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/13/25.
//

import SwiftUI
import SwiftData
import RevenueCat
import AppMetricaCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_lTNKnYnsNiHmmOazPtlVQyQBFIq")
        
        let configuration = AppMetricaConfiguration(apiKey: "45891ccb-5948-4e81-909a-5aca2d193c0a")
        AppMetrica.activate(with: configuration!)
        
        return true
    }
}

@main
struct GiftTextApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
