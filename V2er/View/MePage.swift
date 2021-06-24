//
//  MePage.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct MePage: View {
    var body: some View {
        GeometryReader{ _ in
            Text("ME")
        }
    }
}

struct AccountPage_Previews: PreviewProvider {
    static var previews: some View {
        MePage()
    }
}
