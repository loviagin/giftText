//
//  MainViewModel.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/13/25.
//

import Foundation

class MainViewModel: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var user: User? = nil
    @Published var typeGift: [String] = [
        NSLocalizedString("Birthday", comment: "Type Gift"),
        NSLocalizedString("Wedding", comment: "Type Gift"),
        NSLocalizedString("Christmas", comment: "Type Gift"),
        NSLocalizedString("New Year", comment: "Type Gift"),
        NSLocalizedString("Baby's birth", comment: "Type Gift"),
        NSLocalizedString("Anniversary", comment: "Type Gift")
    ]
    
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
}

extension MainViewModel {
    static var mock: MainViewModel {
        let viewModel = MainViewModel()
        return viewModel
    }
}

enum AppTab {
    case home, history, account
}
