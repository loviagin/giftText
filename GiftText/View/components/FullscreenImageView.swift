//
//  FullscreenImageView.swift
//  GiftText
//
//  Created by Ilia Loviagin on 8/20/25.
//

import SwiftUI

struct FullscreenImageView: View {
    let image: Data?
    var onClose: () -> Void

    @State private var showShare = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image, let uiImage = UIImage(data: image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
            }
            // Кнопка закрытия — справа сверху
            VStack {
                HStack {
                    Spacer()
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.95))
                            .padding(14)
                    }
                    .accessibilityLabel("Close")
                }
                Spacer()
            }

            if let image, let uiImage = UIImage(data: image) {
                // Кнопка скачивания — снизу
                VStack {
                    Spacer()
                    AppButton(text: "Download", systemImage: "arrow.down.circle", onClickText: "Saved", backgroundColor: Color.gray.opacity(0.7)) {
                        ContentHelper.saveToPhotos(uiImage) { result in
                            print(result)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}
