//
//  User.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/13/25.
//

import Foundation
import SwiftData

@Model
class User {
    var id: String = UUID().uuidString
    var name: String? = nil
    
    var subscription: Date? = nil
    var usages: [Date: [String: Int]] = [:]
    
    var registered: Date = Date()
    
    init(id: String, name: String, subscription: Date? = nil, usages: [Date: [String: Int]], registered: Date) {
        self.id = id
        self.name = name
        self.subscription = subscription
        self.usages = usages
        self.registered = registered
    }
    
    init(name: String) {
        self.id = UUID().uuidString
        self.name = name
        self.subscription = nil
        self.usages = [:]
        self.registered = Date()
    }
    
    init() { }
}
