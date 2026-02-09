//
//  AppearanceSettingView.swift
//  V2er
//
//  Created by ghui on 2021/10/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct AppearanceSettingView: View {
    @ObservedObject private var store = Store.shared

    private var currentAppearance: AppearanceMode {
        store.appState.settingState.appearance
    }

    var body: some View {
        List {
            // MARK: - Theme Section
            Section {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Button {
                        dispatch(SettingActions.ChangeAppearanceAction(appearance: mode))
                    } label: {
                        HStack {
                            Text(mode.displayName)
                                .foregroundStyle(.primary)
                            Spacer()
                            if currentAppearance == mode {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                                    .fontWeight(.semibold)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("主题")
            } footer: {
                Text("选择应用的显示外观")
            }
        }
        .navigationTitle("外观设置")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

struct AppearanceSettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AppearanceSettingView()
                .environmentObject(Store.shared)
        }
    }
}
