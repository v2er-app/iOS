//
//  LoginPage.swift
//  V2er
//
//  Created by ghui on 2021/9/19.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct LoginPage: View {
    var selecedTab: TabId
    @State var username: String = .default
    @State var password: String = .default
    @State var captcha: String = .default
    
    var body: some View {
        VStack(alignment: .center) {
            Image("logo")
            //                .roundedEdge(radius: 5)
                .cornerRadius(20)
            Text("Login to V2EX")
                .font(.title2)
                .foregroundColor(.primary)
                .fontWeight(.heavy)
                .padding(.vertical, 20)
            //                .padding(.bottom, 30)
            VStack(spacing: 10) {
                let radius: CGFloat = 8
                let padding: CGFloat = 14
                TextField("Username", text: $username)
                    .padding(padding)
                    .background(Color.lightGray)
                    .cornerRadius(radius)
                SecureField("Password", text: $password)
                    .padding(padding)
                    .background(Color.lightGray)
                    .cornerRadius(radius)
                TextField("Captcha", text: $captcha)
                    .padding(padding)
                    .background(Color.lightGray)
                    .cornerRadius(radius)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            HStack {
                Button(action: {
                    // Do submit
                }) {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(Color.tintColor)
                        .padding()
                        .greedyWidth()
                        .cornerBorder(radius: 15, borderWidth: 2, color: Color.tintColor)
                }
                Button(action: {
                    // Do submit
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .greedyWidth()
                        .background(Color.tintColor)
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal, 16)
            Text("Sign in with Google")
                .font(.headline)
                .greedyWidth(.trailing)
                .padding()
//            Text("Forget password ?")
//                .font(.headline)
//                .greedyWidth(.trailing)
//                .padding(.bottom, 10)
//                .padding(.trailing, 10)
            Spacer()
            HStack {
                Text("FAQ")
                Text("About")
                Text("Forget password?")
            }
            .font(.callout)
        }
        .greedyHeight()
        .background(Color.bgColor)
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage(selecedTab: .me)
    }
}
