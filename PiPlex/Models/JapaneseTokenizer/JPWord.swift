//
//  JPWord.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 28/08/2024.
//

import Foundation
import Dictionary
import CharacterFilter
import Mecab_Swift
import SwiftUI

struct JPWord: ProcessedWord {
    let base: String
    var partOfSpeech: WordPartOfSpeech = .noun
    let range: Range<String.Index>
//    let bounds: CGRect
    let dictionary: JMDictionary
    let dictionaryForm: String
    var dictionaryEntries: [JMDictionaryEntry] = []
    
    var color: UIColor = .black
    
    func isAllowed(filter: CharacterFiltering) -> Bool {
        let characters = Set(base.map { String($0) })
        return characters.isDisjoint(with: filter.disallowedCharacters)
    }
    
    init(annotation: Annotation, /*bounds: CGRect,*/ dictionary: JMDictionary) {
        self.base = annotation.base
        self.range = annotation.range
//        self.bounds = bounds
        self.dictionaryForm = annotation.dictionaryForm
        self.dictionary = dictionary
        
        self.lookupInDictionary(word: self.base)
        self.setPartOfSpeech()
        self.setColor()
        
    }

    private mutating func setPartOfSpeech() {
        guard
            let firstEntry = self.dictionaryEntries.first,
            let firstPartOfSpeech = firstEntry.position.first
        else { return }

        let range = NSRange(location: 0, length: firstPartOfSpeech.utf16.count)

        for pos in WordPartOfSpeech.allCases {
            let regex = pos.regexPattern
            if regex.firstMatch(in: firstPartOfSpeech, options: [], range: range) != nil {
                self.partOfSpeech = pos
                break
            }
        }
    }
    
    private mutating func setColor() {
        let wordColor: UIColor = switch self.partOfSpeech {
        case .noun: .UIWordBlue
        case .particle: .UIWordGreen
        case .verb: .UIWordRed
        case .adjective: .UIWordYellow
        case .adverb: .UIWordPurple
        }
        
        self.color = wordColor
    }
    
    private mutating func lookupInDictionary(word: String) {
        self.dictionaryEntries = self.dictionary.lookup(word)
    }
}
