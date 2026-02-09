//
//  Extension.swift
//  test
//
//  Created by 이웅재 on 2021/08/27.
//

import SwiftUI

extension WebRichText {
    
    public func lineHeight(_ lineHeight: CGFloat) -> WebRichText {
        var result = self
        
        result.lineHeight = lineHeight
        return result
    }
    
    public func imageRadius(_ imageRadius: CGFloat) -> WebRichText {
        var result = self
        
        result.imageRadius = imageRadius
        return result
    }
    
    public func fontType(_ fontType: fontType) -> WebRichText {
        var result = self
        
        result.fontType = fontType
        return result
    }
    
    public func colorScheme(_ colorScheme: colorScheme) -> WebRichText {
        var result = self
        
        result.colorScheme = colorScheme
        return result
    }
    
    public func colorImportant(_ colorImportant: Bool) -> WebRichText {
        var result = self
        
        result.colorImportant = colorImportant
        return result
    }
    
    public func placeholder<T>(@ViewBuilder content: () -> T) -> WebRichText where T : View {
        var result = self
        
        result.placeholder = AnyView(content())
        return result
    }
    
    public func linkOpenType(_ linkOpenType: linkOpenType) -> WebRichText {
        var result = self
        
        result.linkOpenType = linkOpenType
        return result
    }
}
