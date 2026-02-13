//
//  CreateTopicPage.swift
//  CreateTopicPage
//
//  Created by Seth on 2021/7/28.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import PhotosUI

struct CreateTopicPage: StateView {
    @Environment(\.dismiss) var dismiss
    @State var showNodeChooseView = false
    @FocusState private var focusedField: Field?
    @State var isPreviewing = false
    @State private var selectedImage: PlatformImage? = nil
    @State private var isUploadingImage = false

    private enum Field: Hashable {
        case title, content
    }

    @ObservedObject private var store = Store.shared
    var bindingState: Binding<CreateTopicState> {
        return $store.appState.createTopicState
    }

    var body: some View {
        contentView
            .navigationTitle("创作主题")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        if isPreviewing {
                            isPreviewing = false
                            focusedField = .content
                        } else {
                            isPreviewing = true
                            focusedField = nil
                        }
                    } label: {
                        Label(isPreviewing ? "编辑" : "预览",
                              systemImage: isPreviewing ? "pencil" : "eye")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.accentColor)
                    }
                    .disabled(state.title.isEmpty && state.content.isEmpty)
                }
            }
            .onChange(of: state.createResultInfo?.id) { newId in
                guard let newId = newId else { return }
                if newId.notEmpty() {
                    dismiss()
                    dispatch(CreateTopicActions.Reset())
                }
            }
            .onAppear {
                dispatch(CreateTopicActions.LoadDataStart())
                dispatch(CreateTopicActions.LoadAllNodesStart())
            }
    }

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // MARK: - Node Selection
                nodeSelectionCard

                // MARK: - Title & Content Card
                editorCard

                // MARK: - Attachments
                attachmentBar

                // MARK: - Publish
                publishSection
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.lg)
        }
        .onTapGesture { focusedField = nil }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showNodeChooseView) {
            NodeChooserPage(nodes: state.sectionNodes, selectedNode: bindingState.selectedNode)
        }
    }

    // MARK: - Node Selection Card

    @ViewBuilder
    private var nodeSelectionCard: some View {
        Button {
            showNodeChooseView = true
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: "number.square.fill")
                    .font(.title3)
                    .foregroundColor(.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text("节点")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                    Text(state.selectedNode?.text ?? "选择一个节点")
                        .font(.body)
                        .foregroundColor(state.selectedNode != nil ? .primaryText : .tertiaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.tertiaryText)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Editor Card

    @ViewBuilder
    private var editorCard: some View {
        VStack(spacing: 0) {
            // Title field
            TextField("标题", text: bindingState.title, axis: .vertical)
                .font(.body.weight(.semibold))
                .lineLimit(1...3)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .focused($focusedField, equals: .title)
                .onSubmit { focusedField = .content }

            Divider().padding(.leading, Spacing.lg)

            // Content area
            ZStack(alignment: .topLeading) {
                TextEditor(text: bindingState.content)
                    .font(.body)
                    .padding(.horizontal, 10)
                    .frame(minHeight: 200)
                    .focused($focusedField, equals: .content)
                    .opacity(isPreviewing ? 0 : 1)
                    .scrollContentBackground(.hidden)

                if isPreviewing {
                    Text(state.content.attributedString)
                        .font(.body)
                        .textSelection(.enabled)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                        .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
                } else if state.content.isEmpty {
                    Text("如果标题能够表达完整内容, 此处可为空")
                        .font(.body)
                        .foregroundColor(.tertiaryText)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                        .allowsHitTesting(false)
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .onChange(of: selectedImage) { _, newImage in
            guard let image = newImage else { return }
            uploadImage(image)
        }
    }

    // MARK: - Attachment Bar

    @ViewBuilder
    private var attachmentBar: some View {
        HStack(spacing: Spacing.md) {
            if isUploadingImage {
                ProgressView()
                    .frame(width: 20, height: 20)
                Text("上传中...")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            } else {
                UnifiedImagePickerButton(selectedImage: $selectedImage)
                Text("上传图片")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }

    // MARK: - Publish Section

    @ViewBuilder
    private var publishSection: some View {
        VStack(spacing: Spacing.sm) {
            Button {
                focusedField = nil
                dispatch(CreateTopicActions.PostStart())
            } label: {
                if state.posting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Label("发布主题", systemImage: "paperplane.fill")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(state.title.isEmpty || state.selectedNode == nil || state.posting)

            if state.selectedNode == nil {
                Text("请先选择节点")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(.top, Spacing.sm)
    }

    // MARK: - Image Upload

    private func uploadImage(_ image: PlatformImage) {
        isUploadingImage = true
        Task {
            let result = await ImgurService.shared.upload(image: image)
            await MainActor.run {
                isUploadingImage = false
                selectedImage = nil
                if result.success, let imageUrl = result.imageUrl {
                    let record = MyUploadsState.UploadRecord(imageUrl: imageUrl)
                    MyUploadsState.saveUpload(record)
                    let currentContent = state.content
                    let prefix = currentContent.isEmpty || currentContent.hasSuffix("\n") ? "" : "\n"
                    store.appState.createTopicState.content += "\(prefix)\(imageUrl)\n"
                    Toast.show("图片上传成功")
                } else {
                    Toast.show(result.error ?? "图片上传失败")
                }
            }
        }
    }
}

struct CreateTopicPage_Previews: PreviewProvider {
    static var previews: some View {
        CreateTopicPage()
    }
}
