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

    var text: String = ""
    var image: Data? = nil
    
    var type: String? = nil
    var style: MessageStyle? = nil
    var liked: Bool? = nil
    
    var date: Date = Date()
    
    init(id: String, userId: String, chatId: String, text: String = "", image: Data? = nil, type: String? = nil, style: MessageStyle? = nil, liked: Bool? = nil, date: Date) {
        self.id = id
        self.userId = userId
        self.chatId = chatId
        self.text = text
        self.image = image
        self.type = type
        self.style = style
        self.liked = liked
        self.date = date
    }
    
    init(userId: String, chatId: String, text: String = "", image: Data? = nil, type: String? = nil, style: MessageStyle? = nil) {
        self.id = UUID().uuidString
        self.userId = userId
        self.chatId = chatId
        self.text = text
        self.image = image
        self.type = type
        self.style = style
        self.liked = nil
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
