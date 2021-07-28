//
//  MePage.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct MePage: View {
    @Binding var selecedTab: TabId
    
    var body: some View {
        GeometryReader{ _ in
            Text("ME")
        }
        .opacity(selecedTab == .me ? 1.0 : 0.0)
    }
}

struct AccountPage_Previews: PreviewProvider {
    @State static var selected = TabId.me
    
    static var previews: some View {
        MePage(selecedTab: $selected)
    }
}
