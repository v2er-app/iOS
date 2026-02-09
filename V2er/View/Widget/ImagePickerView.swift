//
//  ImagePickerView.swift
//  V2er
//
//  Created for V2er project
//  Image picker wrapper for SwiftUI
//

import SwiftUI
import PhotosUI

#if os(iOS)
struct UnifiedImagePickerButton: View {
    @Binding var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Image(systemName: "photo.on.rectangle")
                .font(.title2.weight(.regular))
                .foregroundColor(.tintColor)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        selectedImage = image
                    }
                }
            }
        }
    }
}
#elseif os(macOS)
struct UnifiedImagePickerButton: View {
    @Binding var selectedImage: NSImage?
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Image(systemName: "photo.on.rectangle")
                .font(.title2.weight(.regular))
                .foregroundColor(.tintColor)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = NSImage(data: data) {
                    await MainActor.run {
                        selectedImage = image
                    }
                }
            }
        }
    }
}
#endif
