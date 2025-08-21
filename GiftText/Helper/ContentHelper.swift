//
//  ContentHelper.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/20/25.
//

import Foundation
import Photos
import UIKit

class ContentHelper {
    static func saveToPhotos(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                completion(.failure(NSError(domain: "PhotoAuth", code: 1, userInfo: [NSLocalizedDescriptionKey: "No access to Photos"])))
                return
            }
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAsset(from: image)
            }, completionHandler: { success, error in
                DispatchQueue.main.async {
                    if let error = error { completion(.failure(error)) }
                    else if success { completion(.success(())) }
                    else {
                        completion(.failure(NSError(domain: "PhotoSave", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                    }
                }
            })
        }
    }
}
