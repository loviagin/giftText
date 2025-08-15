//
//  Message.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/13/25.
//

import Foundation
import SwiftData

@Model
class Message {
    var id: String = UUID().uuidString
    var userId: String = ""
    var chatId: String = ""

    var text: String? = nil
    var image: Data? = nil
    
    var type: String? = nil
    var style: MessageStyle? = nil
    
    var date: Date = Date()
    
    init(id: String, userId: String, chatId: String, text: String? = nil, image: Data? = nil, date: Date) {
        self.id = id
        self.userId = userId
        self.chatId = chatId
        self.text = text
        self.image = image
        self.date = date
    }
    
    init(userId: String, chatId: String, text: String? = nil, image: Data? = nil) {
        self.id = UUID().uuidString
        self.userId = userId
        self.chatId = chatId
        self.text = text
        self.image = image
        self.date = Date()
    }
    
    init() { }
}

enum MessageStyle: String, Codable, CaseIterable {
    case smile = "Smile"
    case romantic = "Romantic"
    case official = "Official"
    case touching = "Touching"
    case byContext = "By Context"
}
