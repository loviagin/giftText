//
//  MainViewModel.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/13/25.
//

import Foundation
import SwiftUI
import RevenueCat

@MainActor
class MainViewModel: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var user: User? = nil
    @Published var subscribed = false
    @Published var newGift: Gift? = nil
    @Published var typeGift: [String] = [
        NSLocalizedString("Birthday", comment: "Type Gift"),
        NSLocalizedString("Wedding", comment: "Type Gift"),
        NSLocalizedString("Christmas", comment: "Type Gift"),
        NSLocalizedString("New Year", comment: "Type Gift"),
        NSLocalizedString("Baby's birth", comment: "Type Gift"),
        NSLocalizedString("Anniversary", comment: "Type Gift"),
        NSLocalizedString("Graduation", comment: "Type Gift"),
        NSLocalizedString("Valentine's Day", comment: "Type Gift"),
        NSLocalizedString("Mother's Day", comment: "Type Gift"),
        NSLocalizedString("Father's Day", comment: "Type Gift"),
        NSLocalizedString("Easter", comment: "Type Gift"),
        NSLocalizedString("Thanksgiving", comment: "Type Gift"),
    ]
    
    init() {
        DispatchQueue.main.async {
            Task {
                self.subscribed = await self.checkSubscription()
            }
        }
    }
    
    func checkSubscription() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            if customerInfo.entitlements["Unlimited Generation"]?.isActive == true {
              // user has access to "Unlimited Generation"
                return true
            } else {
                return false
            }
        } catch {
            print(error)
        }
        
        print(subscribed)
        return false
//        return true
    }
    
    func checkDonationAllowance() async -> Bool {
        let url = "https://gt.nqstx.xyz/donate"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            //decode as DonateDTO
            let donateDTO: DonateDTO = try JSONDecoder().decode(DonateDTO.self, from: data)
            return donateDTO.allowed
        } catch {
            print(error)
            return false
        }
    }
    
    func checkLimitsForRegenerate(_ id: String) -> Bool {
        guard let u = user else {
            return false
        }
        
        guard !subscribed else {
            return true
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        if let todayUsage = u.usages[today],
           let textUsed = todayUsage["\(id)"] {
            print("textRegenerateUsed: \(textUsed) - \(textUsed < 3)")
            return textUsed <= 3
        } else {
            return true
        }
    }
    
    func setLimitForRegenerate(_ id: String) {
        guard let u = user else {
            return
        }
        
        guard !subscribed else {
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        if let todayUsage = u.usages[today],
           let textUsed = todayUsage["textUsed"] {
            print("textRegenerateUsed: \(textUsed) - \(textUsed + 1)")
            user?.usages[today] = ["\(id)": textUsed + 1]
        } else {
            user?.usages[today] = ["\(id)": 1]
        }
    }
    
    func checkLimitsForText() -> Bool {
        guard let u = user else {
            return false
        }
        
        guard !subscribed else {
            return true
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        if let todayUsage = u.usages[today],
           let textUsed = todayUsage["textUsed"] {
            print("textUsed: \(textUsed) - \(textUsed < 10)")
            return textUsed < 10
        } else {
            return true
        }
    }
    
    func setLimitForText() {
        guard let u = user else {
            return
        }
        
        guard !subscribed else {
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        if let todayUsage = u.usages[today],
           let textUsed = todayUsage["textUsed"] {
            print("textUsed: \(textUsed) - \(textUsed + 1)")
            user?.usages[today] = ["textUsed": textUsed + 1]
        } else {
            user?.usages[today] = ["textUsed": 1]
        }
    }
    
    func checkLimitsForImage() -> Bool {
        guard !subscribed else {
            return true
        }
        
        return !UserDefaults.standard.bool(forKey: "imageUsed")
    }
    
    func setLimitForImage() {
        guard !subscribed else {
            return
        }
        
        UserDefaults.standard.set(true, forKey: "imageUsed")
    }
    
    func findUser(_ users: [User]) -> User? {
        if let user = users.first {
            DispatchQueue.main.async {
                self.user = user
            }
            
            return nil
        } else {
            let newUser = User()
            DispatchQueue.main.async {
                self.user = newUser
            }
            
            return newUser
        }
    }
    
    func imageFromBase64(_ base64: String) -> UIImage? {
        // Если пришло как data URL — обрежем префикс
        let cleaned = base64.replacingOccurrences(of: #"^data:image/[^;]+;base64,"#,
                                                  with: "",
                                                  options: .regularExpression)

        guard let data = Data(base64Encoded: cleaned, options: .ignoreUnknownCharacters) else {
            return nil
        }

        guard let uiImage = UIImage(data: data) else { return nil }
        return uiImage
    }
}

extension MainViewModel {
    static var mock: MainViewModel {
        let viewModel = MainViewModel()
        viewModel.selectedTab = .account
        return viewModel
    }
}

enum AppTab {
    case home, history, account
}
