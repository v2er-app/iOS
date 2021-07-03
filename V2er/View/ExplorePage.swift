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
        //        GeometryReader{ _ in
        //            Text("ExplorePage")
        //                .navigationBarTitle("Explore")
        //        }
        //        .border(.red, width: 2)
        
        
        VStack {
            Text("Today's Weather")
                .font(.title)
                .border(Color.gray)
            
            HStack {
                Text("1🌧")
                    .alignmentGuide(VerticalAlignment.top) { _ in 10 }
                Text("Rain & Thunderstorms")
                    .border(Color.gray)
                Text("2⛈")
                    .alignmentGuide(VerticalAlignment.top) { _ in 10 }
                    .border(Color.gray)
            }
            .border(.red)
        }
    }
}

struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExplorePage()
    }
}
