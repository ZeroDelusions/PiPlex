//
//  JPSentence.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 28/08/2024.
//

import Foundation
import CharacterFilter
import Mecab_Swift

class JPSentence: ProcessedSentence {
    
    typealias WordType = JPWord
    
    private typealias AnnotationWithBounds = (data: Annotation, bounds: CGRect)
    
    var text: String
    var words: [JPWord] = []
    let bounds: CGRect
    
    private var annotations: [Annotation] = []
    
    init(text: String, annotations: [Annotation], bounds: CGRect, dictionary: JMDictionary) {
        self.text = text
        self.bounds = bounds
        self.annotations = annotations
        self.generateJPWords(using: dictionary)
    }
    
    subscript(index: Int) -> JPWord {
        return words[index]
    }
    
    var count: Int {
        return words.count
    }
    
    func filter(using filter: CharacterFiltering) -> [JPWord] {
        return words.filter { $0.isAllowed(filter: filter) }
    }
    
    private func generateJPWords(using dict: JMDictionary) {
        self.words = self.annotations.map { annotation in
            JPWord(annotation: annotation, /*bounds: annotation.bounds,*/ dictionary: dict)
        }
    }
    
    /// Calculate bounds of each word for more complex styles for text in PiPViewRepresentable
//    private func calculateAnnotationsBounds(_ annotations: [Annotation])  {
//        var annotationWithBounds: [AnnotationWithBounds] = []
//        
//        let sentenceCharCount = CGFloat(self.text.count)
//        let singleCharSize = CGSize(
//            width: self.bounds.size.width / sentenceCharCount,
//            height: self.bounds.size.height / sentenceCharCount
//        )
//        
//        let originX = bounds.origin.x
//        let originY = bounds.origin.y
//        
//        for annotation in annotations {
//            let startIndex = annotation.range.lowerBound
//            let endIndex = annotation.range.upperBound
//            
//            let startCharIndex = CGFloat(startIndex.utf16Offset(in: self.text))
//            let endCharIndex = CGFloat(endIndex.utf16Offset(in: self.text))
//            
//            let wordWidth = (endCharIndex - startCharIndex) * singleCharSize.width
//            let wordHeight = singleCharSize.height
//            
//            let wordOriginX = originX + startCharIndex * singleCharSize.width
//            let wordOriginY = originY
//            
//            let wordRect = CGRect(x: wordOriginX, y: wordOriginY, width: wordWidth, height: wordHeight)
//            annotationWithBounds.append((data: annotation, bounds: wordRect))
//        }
//        
//       self.annotations = annotationWithBounds
//    }
}

extension JPSentence {
    func isEqual(to other: JPSentence) -> Bool {
        self.text == other.text
    }
}
