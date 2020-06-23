//
//  Home.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct HomePage: View {
    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                self.topBar()
                Divider()
                    .frame(height: 0.1)
                ScrollView (.vertical, showsIndicators: false) {
                    Text("Line1 Line1 Line1")
                }
            }
        }
    }
    
    func topBar() -> some View {
        ZStack {
            HStack {
                Button (action: {
                    
                }) {
                    Image(systemName: "square.grid.2x2")
                        .foregroundColor(.primary)
                        .font(.system(size: 22))
                        .padding(6)
                }
                Spacer()
                Button (action: {
                    //
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.primary)
                        .font(.system(size: 22))
                        .padding(6)
                }
                
            }.padding()
            
            Text("V2EX")
                .font(.title)
                .foregroundColor(.primary)
                .fontWeight(.heavy)
        }.background(VEBlur())
    }
    
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
