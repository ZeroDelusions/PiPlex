//
//  ProcessedTextProtocol.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 29/08/2024.
//

import Foundation
import UIKit

enum WordPartOfSpeech: String, CaseIterable {
    case noun
    case particle
    case verb
    case adjective
    case adverb
    
    var regexPattern: NSRegularExpression {
        let pattern = "\\b\(self.rawValue)\\b"
        return try! NSRegularExpression(pattern: pattern, options: [])
    }
}

protocol ProcessedWord {
    var base: String { get }
    var partOfSpeech: WordPartOfSpeech { get }
    var color: UIColor { get }
    var range: Range<String.Index> { get }
    var dictionaryEntries: [JMDictionaryEntry] { get }
}

protocol ProcessedSentence {
    
    associatedtype WordType: Equatable, ProcessedWord
    var text: String { get }
    var words: [WordType] { get }
    var bounds: CGRect { get }
    
    func isEqual(to other: Self) -> Bool
}

func areSentencesEqual(_ lhs: [any ProcessedSentence], _ rhs: [any ProcessedSentence]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    return zip(lhs, rhs).allSatisfy {
        guard let left = $0 as? AnyHashable, let right = $1 as? AnyHashable else {
            return false
        }
        return left == right
    }
}


