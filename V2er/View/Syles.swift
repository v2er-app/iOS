//
//  styles.swift
//  V2er
//
//  Created by Seth on 2021/7/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct OvalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        let bg = LinearGradient(gradient: Gradient(colors: [Color.orange, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
        configuration
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.lightGray)
            .cornerRadius(20)
            .foregroundColor(.bodyText)
    }
}

struct styles_Previews: PreviewProvider {
    @State private static var name: String = ""
    
    static var previews: some View {
        TextField("Name1:", text: $name)
            .textFieldStyle(OvalTextFieldStyle())
    }
}

