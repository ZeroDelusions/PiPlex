//
//  JPFilter.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 30/08/2024.
//

import Foundation

class JPFilter {
    
    func filter(text: String) {
        
    }
    
    func containsOnlyJapaneseCharacters(_ input: String) -> Bool {
        let japaneseCharacterPattern = "^[\\p{Hiragana}\\p{Katakana}\\p{Han}\\p{P}\\p{Z}\\p{S}\\p{N}]*$"
        
        let regex = try! NSRegularExpression(pattern: japaneseCharacterPattern, options: [])
        
        let range = NSRange(location: 0, length: input.utf16.count)
        return regex.firstMatch(in: input, options: [], range: range) != nil
    }
    
}
