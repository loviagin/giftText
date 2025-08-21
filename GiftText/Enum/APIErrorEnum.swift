//
//  APIErrorEnum.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/20/25.
//

import Foundation

enum APIError: Error { case badStatus(Int), emptyBody }
