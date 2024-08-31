//
//  JPWord+Equatable.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 29/08/2024.
//

import Foundation

extension JPWord: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        let isSameBase = lhs.base == rhs.base
        let isSameRange = lhs.range == rhs.range
        let isSamePartOfSpeech = lhs.partOfSpeech == rhs.partOfSpeech
        let isSameDictionaryForm = lhs.dictionaryForm == rhs.dictionaryForm
        return isSameBase && isSameRange && isSamePartOfSpeech && isSameDictionaryForm
    }
    
    static func != (lhs: Self, rhs: Self) -> Bool {
        return !(lhs == rhs)
    }
}
