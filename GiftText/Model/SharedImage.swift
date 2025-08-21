//
//  SharedImage.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/19/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct SharedImage: Transferable {
    let data: Data
    let filename: String
    let utType: UTType

    init?(uiImage: UIImage,
          filename: String = "image.png",
          asPNG: Bool = true,
          jpegQuality: CGFloat = 0.9) {
        if asPNG, let d = uiImage.pngData() {
            self.data = d
            self.utType = .png
            self.filename = filename
        } else if let d = uiImage.jpegData(compressionQuality: jpegQuality) {
            self.data = d
            self.utType = .jpeg
            self.filename = (filename as NSString).deletingPathExtension + ".jpg"
        } else {
            return nil
        }
    }

    static var transferRepresentation: some TransferRepresentation {
        // Отдаём как PNG
        DataRepresentation(exportedContentType: .png) { (item: SharedImage) in
            if item.utType == .png {
                return item.data
            } else {
                // Перекодируем JPEG->PNG при необходимости
                return UIImage(data: item.data)?.pngData() ?? item.data
            }
        }
        .suggestedFileName { (item: SharedImage) in
            let base = (item.filename as NSString).deletingPathExtension
            return item.utType == .png ? item.filename : "\(base).png"
        }

        // И отдельно — как JPEG
        DataRepresentation(exportedContentType: .jpeg) { (item: SharedImage) in
            if item.utType == .jpeg {
                return item.data
            } else {
                // Перекодируем PNG->JPEG при необходимости
                return UIImage(data: item.data)?.jpegData(compressionQuality: 0.9) ?? item.data
            }
        }
        .suggestedFileName { (item: SharedImage) in
            let base = (item.filename as NSString).deletingPathExtension
            return item.utType == .jpeg ? item.filename : "\(base).jpg"
        }
    }
}
