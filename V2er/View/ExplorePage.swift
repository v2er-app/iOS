//
//  ExplorePage.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct ExplorePage: View {
    var body: some View {
        //        GeometryReader{ geo in
        VStack {
            
            GeometryReader { _ in
                Text("ExplorePage")
                    .navigationBarTitle("Explore")
            }
        }
        //        }
        .border(.red, width: 2)
    }
}

struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExplorePage()
    }
}
