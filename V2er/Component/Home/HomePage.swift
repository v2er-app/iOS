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
        NavigationView {
            ZStack(alignment: .top) {
                ScrollView (.vertical, showsIndicators: false) {
                    ForEach( 0...60, id: \.self) { i in
                        Text(" LineLineLineLineLineLineLineLineLine Number \(i)   ")
                            .background(i % 5 == 0 ? Color.blue : Color.clear)
                    }
                    .padding(.top, 100)
                    .padding(.bottom, 80)
                }
                topBar
            }.navigationBarHidden(true)
            .edgesIgnoringSafeArea(.top)
        }
    }
    
    private var topBar : some View {
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

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
