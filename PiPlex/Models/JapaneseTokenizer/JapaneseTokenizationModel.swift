//
//  JapaneseTokenizationModel.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 28/08/2024.
//

import Foundation
import IPADic
import Mecab_Swift
import Dictionary
import CharacterFilter
import UIKit

class JapaneseTokenizationModel: ObservableObject {
    
    @Published var sentences: [JPSentence] = []
    
    let jmDictionary = JMDictionary()
    let ipadic = IPADic()
    let unidic = UniDic()
    let tokenizer: Tokenizer
    
    init() {
        do {
            self.tokenizer = try Tokenizer(dictionary: self.unidic)
        } catch {
            fatalError("Error initialising Tokenizer with dictionary \(self.unidic)")
        }
    }
 
    func tokenize(recognizedText: [TextRecognitionData], transliteration: Tokenizer.Transliteration = .hiragana) {
        DispatchQueue.global(qos: .userInitiated).async {
            var sentences: [JPSentence] = []
            
            for (text, bounds) in recognizedText {
                let annotations = self.tokenizer.tokenize(text: text, transliteration: .hiragana)
                let sentence = JPSentence(text: text, annotations: annotations, bounds: bounds, dictionary: self.jmDictionary)
                
                sentences.append(sentence)
            }
            
            DispatchQueue.main.async {
                self.sentences = sentences
            }
        }
    }
}
