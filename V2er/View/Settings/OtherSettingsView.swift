//
//  OtherSettingsView.swift
//  V2er
//
//  Created by ghui on 2021/10/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import Kingfisher

struct OtherSettingsView: View {
    @State var sizeM: CGFloat = 0

    var body: some View {
        formView
            .navBar("其他设置")
            .task {
                ImageCache.default.calculateDiskStorageSize { result in
                    switch result {
                        case .success(let size):
                            sizeM = CGFloat(size) / 1024 / 1024
                            log("Disk cache size: \(sizeM)MB")
                        case .failure(let error):
                            print(error)
                    }
                }
            }
    }

    @ViewBuilder
    private var formView: some View {
        ScrollView {
            Button {
                ImageCache.default.clearDiskCache {
                    sizeM = 0
                    Toast.show("缓存清理完成")
                }
            } label: {
                SectionView("缓存") {
                    HStack {
                        let size = String(format: "%.2f", sizeM)
                        Text("\(size)MB")
                            .font(.footnote)
                            .foregroundColor(Color.tintColor)
                        Image(systemName: "chevron.right")
                            .font(.body.weight(.regular))
                            .foregroundColor(.gray)
                            .padding(.trailing, 16)
                    }
                }
            }
        }
    }
}

struct OtherSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        OtherSettingsView()
    }
}
