//
//  TopBar.swift
//  V2er
//
//  Created by Seth on 2021/6/24.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct TopBar: View {
    @Binding var selectedTab : TabId
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button (action: {
                        
                    }) {
                        Image(systemName: "square.grid.2x2")
                            .foregroundColor(.primary)
                            .font(.system(size: 22))
                            .padding(3)
                    }
                    Spacer()
                    Button (action: {
                        //
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary)
                            .font(.system(size: 22))
                            .padding(3)
                    }
                    
                }.padding()
                
                Text("V2EX")
                    .font(.title)
                    .foregroundColor(.primary)
                    .fontWeight(.heavy)
            }
            .padding(.top, safeAreaInsets()?.top)
            .background(VEBlur())
            
            Divider()
                .frame(height: 0.1)
        }
    }
}

struct TopBar_Previews: PreviewProvider {
    @State static var selecedTab = TabId.feed
    
    static var previews: some View {
        TopBar(selectedTab: $selecedTab)
    }
}
