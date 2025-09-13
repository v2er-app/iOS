//
//  AppearanceSettingView.swift
//  V2er
//
//  Created by ghui on 2021/10/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct AppearanceSettingView: View {
    @EnvironmentObject private var store: Store
    @State private var selectedAppearance: AppearanceMode = .system
    
    var body: some View {
        formView
            .navBar("外观设置")
            .onAppear {
                selectedAppearance = store.appState.settingState.appearance
            }
    }

    @ViewBuilder
    private var formView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Dark Mode Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("主题")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    VStack(spacing: 0) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Button(action: {
                                selectedAppearance = mode
                                dispatch(SettingActions.ChangeAppearanceAction(appearance: mode))
                            }) {
                                HStack {
                                    Text(mode.displayName)
                                        .foregroundColor(.primaryText)
                                    Spacer()
                                    if selectedAppearance == mode {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.tintColor)
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .background(Color.itemBackground)
                            }
                            
                            if mode != AppearanceMode.allCases.last {
                                Divider()
                                    .padding(.leading)
                            }
                        }
                    }
                    .background(Color.itemBackground)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.top)
                
                // Font Size Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("字体")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                        .padding(.horizontal)
                        .padding(.top, 24)
                    
                    SectionItemView("字体大小")
                        .background(Color.itemBackground)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
        }
        .background(Color.background.ignoresSafeArea())
    }
}

struct AppearanceSettingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppearanceSettingView()
                .environmentObject(Store.shared)
                .environment(\.colorScheme, .light)
            
            AppearanceSettingView()
                .environmentObject(Store.shared)
                .environment(\.colorScheme, .dark)
        }
    }
}