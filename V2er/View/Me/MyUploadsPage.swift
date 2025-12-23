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
    @State private var selectedUpload: MyUploadsState.UploadRecord?
    @State private var showingDetail = false

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        contentView
            .navBar("我的图片")
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
                            .onLongPressGesture {
                                selectedUpload = upload
                                showingDetail = true
                            }
                    }
                }
                .padding(2)
            }
            .background(Color.bgColor)
            .sheet(isPresented: $showingDetail) {
                if let upload = selectedUpload {
                    UploadDetailSheet(upload: upload, onDelete: {
                        deleteUpload(upload)
                        showingDetail = false
                    })
                }
            }
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

    private func deleteUpload(_ upload: MyUploadsState.UploadRecord) {
        MyUploadsState.deleteUpload(upload)
        loadUploads()
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

struct UploadDetailSheet: View {
    let upload: MyUploadsState.UploadRecord
    let onDelete: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Image preview
                KFImage(URL(string: upload.imageUrl))
                    .cacheOriginalImage()
                    .loadDiskFileSynchronously()
                    .placeholder {
                        Color.lightGray
                            .frame(height: 200)
                            .overlay {
                                ProgressView()
                            }
                    }
                    .onFailure { error in
                        log("KFImage load failed: \(error.localizedDescription)")
                    }
                    .fade(duration: 0.25)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 400)
                    .padding()

                Divider()

                // URL display and actions
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("图片链接")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                        Text(upload.imageUrl)
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundColor(.primaryText)
                            .lineLimit(2)
                            .padding(12)
                            .background(Color.lightGray)
                            .cornerRadius(8)
                    }
                    .greedyWidth(.leading)

                    HStack(spacing: 16) {
                        Button {
                            UIPasteboard.general.string = upload.imageUrl
                            Toast.show("链接已复制")
                        } label: {
                            Label("复制链接", systemImage: "doc.on.doc")
                                .font(.callout)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.tintColor)
                                .cornerRadius(10)
                        }

                        Button {
                            onDelete()
                        } label: {
                            Label("删除", systemImage: "trash")
                                .font(.callout)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }

                    // Upload time
                    Text("上传于 \(formatDate(upload.timestamp))")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                .padding()

                Spacer()
            }
            .background(Color.bgColor)
            .navigationTitle("图片详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func formatDate(_ timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

struct MyUploadsPage_Previews: PreviewProvider {
    static var previews: some View {
        MyUploadsPage()
    }
}
