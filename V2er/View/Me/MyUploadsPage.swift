//
//  MyUploadsPage.swift
//  V2er
//
//  Created for V2er project
//  Page to display user's uploaded images
//

import SwiftUI
import Kingfisher

struct MyUploadsPage: View {
    @State private var uploads: [MyUploadsState.UploadRecord] = []

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        contentView
            .navigationTitle("我的图片")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadUploads()
            }
    }

    @ViewBuilder
    private var contentView: some View {
        if uploads.isEmpty {
            emptyView
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(uploads) { upload in
                        UploadThumbnailView(upload: upload)
                            .onTapGesture {
                                UIPasteboard.general.string = upload.imageUrl
                                Toast.show("链接已复制")
                            }
                    }
                }
                .padding(2)
            }
            .background(Color.bgColor)
        }
    }

    @ViewBuilder
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.secondaryText)
            Text("暂无上传的图片")
                .font(.headline)
                .foregroundColor(.secondaryText)
            Text("在回复或创建主题时上传的图片会显示在这里")
                .font(.caption)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .greedyFrame()
        .background(Color.bgColor)
    }

    private func loadUploads() {
        uploads = MyUploadsState.loadUploads()
    }
}

struct UploadThumbnailView: View {
    let upload: MyUploadsState.UploadRecord

    var body: some View {
        GeometryReader { geometry in
            KFImage(URL(string: upload.thumbnailUrl ?? upload.imageUrl))
                .placeholder {
                    Color.lightGray
                        .overlay {
                            ProgressView()
                        }
                }
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.width)
                .clipped()
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct MyUploadsPage_Previews: PreviewProvider {
    static var previews: some View {
        MyUploadsPage()
    }
}
