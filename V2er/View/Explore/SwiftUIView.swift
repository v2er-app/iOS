//
//  SwiftUIView.swift
//  SwiftUIView
//
//  Created by Seth on 2021/7/24.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct SwiftUIView: View {
    
    var index: Int = 0
    
    init(_ index: Int) {
        self.index = index
        if index == 1 {
            print("-------- init ----------")
        }
    }
    
    var body: some View {
        Text("Node\(index)")
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView(0)
    }
}
