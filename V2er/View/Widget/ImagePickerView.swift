//
//  ImagePickerView.swift
//  V2er
//
//  Created for V2er project
//  Image picker wrapper for SwiftUI
//

import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
struct PhotosPickerButton: View {
    @Binding var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Image(systemName: "photo.on.rectangle")
                .font(.title2.weight(.regular))
                .foregroundColor(.tintColor)
        }
        .onChange(of: selectedItem) { newItem in
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

// Fallback for iOS 15
struct ImagePickerButton: View {
    @Binding var selectedImage: UIImage?
    @State private var showPicker = false

    var body: some View {
        Button {
            showPicker = true
        } label: {
            Image(systemName: "photo.on.rectangle")
                .font(.title2.weight(.regular))
                .foregroundColor(.tintColor)
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

// Unified view that works on both iOS 15 and 16+
struct UnifiedImagePickerButton: View {
    @Binding var selectedImage: UIImage?

    var body: some View {
        if #available(iOS 16.0, *) {
            PhotosPickerButton(selectedImage: $selectedImage)
        } else {
            ImagePickerButton(selectedImage: $selectedImage)
        }
    }
}
