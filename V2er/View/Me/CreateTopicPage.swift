//
//  CreateTopicPage.swift
//  CreateTopicPage
//
//  Created by Seth on 2021/7/28.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct CreateTopicPage: StateView {
    @Environment(\.dismiss) var dismiss
    @State var showNodeChooseView = false
    @FocusState private var focused: Bool
    @State var isPreviewing = false
//    @State var openTheCreatedTopic = false

    @EnvironmentObject private var store: Store
    var bindingState: Binding<CreateTopicState> {
        return $store.appState.createTopicState
    }

    var body: some View {
        NavigationView {
            contentView
                .safeAreaInset(edge: .top, spacing: 0) { navBar }
                .ignoresSafeArea(.container)
                .navigationBarHidden(true)
//                .to(if: $openTheCreatedTopic) {
//                    FeedDetailPage(initData: FeedInfo.Item(id: state.createResultInfo!.id))
//                }
                .onChange(of: state.createResultInfo?.id) { newId in
                    guard let newId = newId else { return }
                    if newId.notEmpty() {
//                        openTheCreatedTopic = true
                        dismiss()
                        dispatch(CreateTopicActions.Reset())
                    }
                }
                .onAppear {
                    dispatch(CreateTopicActions.LoadDataStart())
                    dispatch(CreateTopicActions.LoadAllNodesStart())
                }
        }
        .ignoresSafeArea(.container)
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private var navBar: some View {
        NavbarView {
            Text("创作主题")
                .font(.headline)
        } contentView: {
            HStack {
                Spacer()
                Button {
                    if isPreviewing {
                        // continue edit
                        isPreviewing = false
                        focused = true
                    } else {
                        isPreviewing = true
                        focused = false
                    }
                } label: {
                    Text(isPreviewing ? "编辑" : "预览")
                        .font(.callout)
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.tintColor)
                        .cornerRadius(10)
                }
                .disabled(state.title.isEmpty)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        } onBackPressed: {
            dismiss()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 0) {
            let paddingH: CGFloat = 16
            TextField("标题", text: bindingState.title)
                .padding(.vertical)
                .padding(.horizontal, paddingH)
                .background(Color.itemBg)
                .lineLimit(3)
                .divider()
                .greedyWidth()
                .focused($focused)
            TextEditor(text: bindingState.content)
                .padding(.horizontal, 10)
                .opacity(isPreviewing ? 0 : 1.0)
                .background(Color.itemBg)
                .frame(maxWidth: .infinity, minHeight: 250)
                .divider()
                .focused($focused)
                .overlay {
                    Group {
                        if state.content.isEmpty {
                            // show placeholder
                            Text("如果标题能够表达完整内容, 此处可为空")
                                .greedyFrame(.topLeading)
                                .foregroundColor(.gray)
                                .debug()
                        } else if isPreviewing {
                            Text(state.content.attributedString)
                                .greedyFrame(.topLeading)
                        }
                    }
                    .textSelection(.enabled)
                    .padding(.horizontal, paddingH)
                    .padding(.vertical, 10)
                }
            Button {
                showNodeChooseView = true
            } label: {
                sectionItemView
                    .foregroundColor(Color.tintColor)
                    .background(Color.itemBg)
            }
            .sheet(isPresented: $showNodeChooseView) {
                NodeChooserPage(nodes: state.sectionNodes, selectedNode: bindingState.selectedNode)
            }

            HStack {
                Spacer()
                Button {
                    dispatch(CreateTopicActions.PostStart())
                } label: {
                    Text("发布主题")
                        .font(.callout)
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.tintColor)
                        .cornerRadius(10)
                }
                .disabled(state.title.isEmpty || state.selectedNode == nil)
                .padding()
            }
            Spacer()
        }
        .onScroll { _ in
            focused = false
        }
        .background(Color.bgColor)
    }

    @ViewBuilder
    private var sectionItemView: some View {
        HStack {
            Image(systemName: "grid.circle")
                .foregroundColor(.gray)
            Text(state.selectedNode?.text ?? "选择节点")
            Spacer()
            Image(systemName: "chevron.right")
                .font(.body.weight(.regular))
                .foregroundColor(.gray)
                .padding(.trailing)
        }
        .padding()
        .forceClickable()
        .divider()
    }
}

struct CreateTopicPage_Previews: PreviewProvider {
    //    @State private static var title: String
    static var previews: some View {
        CreateTopicPage()
    }
}
