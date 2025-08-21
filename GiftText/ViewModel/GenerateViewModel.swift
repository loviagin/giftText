//
//  GenerateViewModel.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/15/25.
//

import Foundation

class GenerateViewModel: ObservableObject {
    private let session: URLSession
    private var prompt: String? = nil
    
    init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 180   // ожидание ответа сервера
        cfg.timeoutIntervalForResource = 300  // полный таймаут всего запроса
        session = URLSession(configuration: cfg)
    }
    
    func initGenerator(myName: String? = nil, name: String, type: String, style: String, gender: String?, context: String?, messages: [Message]?, completion: @escaping (String?) -> Void) async {
        
        var prompt = ""
        prompt += NSLocalizedString("Hi. I need to create a greeting card for \(type).", comment: "Generator")
        if let myName {
            prompt += NSLocalizedString(" My name is \(myName).", comment: "Generator")
        }
        prompt += NSLocalizedString(" For \(name).", comment: "Generator")
        if let gender {
            prompt += NSLocalizedString(" It prefers to be a \(gender).", comment: "Generator")
        }
        prompt += NSLocalizedString(" I want you to write it in a \(style) style.", comment: "Generator")
        prompt += NSLocalizedString(" Do it as humanly as possible.", comment: "Generator")
        if context == nil && messages == nil {
            prompt += NSLocalizedString(" Don't make it too big.", comment: "Generator")
        } else {
            if let messages, !messages.isEmpty { // chat is attached
                prompt += NSLocalizedString(" Here are the latest congratulations:", comment: "Generator")
                for message in messages {
                    prompt += "\n\(message.userId):"
                    prompt += "\(message.text)"
                    if message.userId == "system" {
                        if let like = message.liked {
                            prompt += NSLocalizedString(". The user said that he \(like ? "liked" : "didn't like") it.", comment: "Generator")
                        }
                    }
                }
                
                prompt += NSLocalizedString(" Make it about the same length as in the liked greetings.", comment: "Generator")
            } else if let context, !context.isEmpty { // there is context
                prompt += NSLocalizedString(" Here are the latest congratulations:", comment: "Generator")
                prompt += "\n\(context)."
                prompt += NSLocalizedString(" Make it about the same length as in the  context.", comment: "Generator")
            }
        }
        
        prompt += NSLocalizedString(" Maximum of 7 sentences.", comment: "Generator")
        prompt += NSLocalizedString(" That's all I have. Based on this, make a greeting card without additional questions.", comment: "Generator")
        prompt += NSLocalizedString(" Without any introductory words, the text of congratulations immediately follows.", comment: "Generator")
        
        self.prompt = prompt
        print(prompt)
        
        await generateText() { result in
            completion(result)
        }
    }
    
    func clear() {
        self.prompt = nil
    }
    
    func generateText(completion: @escaping (String?) -> Void) async {
        guard let prompt = self.prompt else { return }
        
        do {
            let result = try await self.fetchGemini(prompt: prompt)
            completion(result)
            
        } catch {
            print(error)
            completion(nil)
        }
    }
    
    func generateImage(completion: @escaping (String?) -> Void) async {
        guard let prompt = self.prompt else { return }
        
        do {
            let result = try await self.fetchImagen(prompt: prompt)
            completion(result)
        } catch {
            print(error)
            completion(nil)
        }
    }
    
    //MARK: - private funcs next
    private func fetchImagen(prompt: String, authToken: String? = nil) async throws -> String {
        var req = URLRequest(url: API.baseURL.appendingPathComponent("imagen"))
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let authToken { req.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization") }

        struct Payload: Encodable { let prompt: String }
        req.httpBody = try JSONEncoder().encode(Payload(prompt: prompt))

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.emptyBody }
        guard (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "<no body>"
            throw APIError.badStatus(http.statusCode) // при желании заверни msg
        }

        guard !data.isEmpty, let b64 = String(data: data, encoding: .utf8) else {
            throw APIError.emptyBody
        }
        return b64
    }
    
//    private func fetchImagen(prompt: String, completion: @escaping (String?) -> Void) async throws {
//        let payload = [
//            "instances": [
//              [
//                "prompt":  "\(prompt) \(NSLocalizedString("No labels, no text, just a picture. NO TEXT ON IMAGE!!!", comment: "Generator"))"
//              ],
//            ],
//            "parameters": [
//                "sampleCount": 1
//            ]
//        ] as [String : Any]
//        
//        let url = "https://generativelanguage.googleapis.com/v1beta/models/imagen-4.0-generate-001:predict"
//        
//        var request = URLRequest(url: URL(string: url)!)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(Credentials.imagenKey, forHTTPHeaderField: "x-goog-api-key")
//        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
//        
//        let (data, _) = try await URLSession.shared.data(for: request)
//        let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//        
//        print(response)
//        
//        if let candidates = response?["predictions"] as? [[String: Any]],
//           let text = candidates.first?["bytesBase64Encoded"] as? String {
//            print("Generated text: \(text)")
//            completion(text)
//        } else {
//            //next code is for fail
//            completion(nil)
//        }
//    }
    
    private func fetchGemini(prompt: String, authToken: String? = nil) async throws -> String {
        var req = URLRequest(url: API.baseURL.appendingPathComponent("gemini"))
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let authToken { req.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization") }
        
        let payload = GenerateDTO(prompt: prompt)
        req.httpBody = try JSONEncoder().encode(payload)
        
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.emptyBody }
        guard (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "<no body>"
            throw APIError.badStatus(http.statusCode) // можно завернуть msg в ошибку
        }
        guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else {
            throw APIError.emptyBody
        }
        return text
    }
    
//    private func fetchGemini(prompt: String, completion: @escaping (String?) -> Void) async throws {
//        let payload = [
//            "contents": [
//              [
//                "parts": [
//                  [ "text": prompt ],
//                ],
//              ],
//            ],
//          ]
//        
//        let url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
//        
//        var request = URLRequest(url: URL(string: url)!)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(Credentials.geminiKey, forHTTPHeaderField: "x-goog-api-key")
//        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
//        
//        let (data, _) = try await URLSession.shared.data(for: request)
//        let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//        if let candidates = response?["candidates"] as? [[String: Any]],
//           let content = candidates.first?["content"] as? [String: Any],
//           let parts = content["parts"] as? [[String: Any]],
//           let text = parts.first?["text"] as? String {
//            print("Generated text: \(text)")
//            completion(text)
//        } else {
//            //next code is for fail
//            completion(nil)
//        }
//    }
}
