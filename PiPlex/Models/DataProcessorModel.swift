//
//  DataProcessorModel.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 10/08/2024.
//

import Foundation
import UIKit


class DataProcessorModel {
    let textRecognition: TextRecognitionModel
    let japaneseTokenization: JapaneseTokenizationModel
    
    init(textRecognition: TextRecognitionModel, japaneseTokenization: JapaneseTokenizationModel) {
        self.textRecognition = textRecognition
        self.japaneseTokenization = japaneseTokenization
    }
    
    func processData(_ data: Data, in rect: CGRect, fullImageSize: CGSize) {
        /// Convert to normalized CGRect
        /// VNRecognizeTextRequest expects regionOfInterest to be normalized CGRect with values in range from 0 to 1
        let normalizedRect = self.normalizeRect(rect, in: fullImageSize)
        textRecognition.performTextRecognition(on: data, inRegion: normalizedRect) { text in
            guard let text else { return }
            self.japaneseTokenization.tokenize(recognizedText: text, transliteration: .hiragana)
        }
    }
    
    private func normalizeRect(_ rect: CGRect, in fullImageSize: CGSize) -> CGRect? {
        let normalizedRect = CGRect(
            x: rect.origin.x / fullImageSize.width,
            y: (fullImageSize.height - rect.origin.y - rect.height) / fullImageSize.height,
            width: rect.width / fullImageSize.width,
            height: rect.height / fullImageSize.height
        )

        /// Ensure the rect is within bounds
        guard normalizedRect.minX >= 0, normalizedRect.minY >= 0,
              normalizedRect.maxX <= 1, normalizedRect.maxY <= 1 else {
            assert(true, "Normalized rect is out of bounds")
            return nil
        }
        
        return normalizedRect
    }
}
