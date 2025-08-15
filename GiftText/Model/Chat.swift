//
//  Chat.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/13/25.
//

import Foundation
import SwiftData

@Model
class Chat {
    var id: String = UUID().uuidString
    var title: String = ""
    
    var lastTime: Date = Date()
    var lastMessage: String? = nil
    var lastId: String? = nil // system or user
    
    var context: String = ""
    
    var createdAt: Date = Date()
    
    init(id: String, title: String, lastTime: Date, lastMessage: String? = nil, lastId: String? = nil, context: String, createdAt: Date) {
        self.id = id
        self.title = title
        self.lastTime = lastTime
        self.lastMessage = lastMessage
        self.lastId = lastId
        self.context = context
        self.createdAt = createdAt
    }
    
    init(title: String, lastTime: Date, lastMessage: String? = nil, lastId: String? = nil, context: String = "") {
        self.id = UUID().uuidString
        self.title = title
        self.lastTime = lastTime
        self.lastMessage = lastMessage
        self.lastId = lastId
        self.context = context
        self.createdAt = Date()
    }
    
    init() { }
}
