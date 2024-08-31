//
//  TextRecognitionModel.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 10/08/2024.
//

import Vision

public typealias TextRecognitionData = (text: String, bounds: CGRect)

class TextRecognitionModel {
    private lazy var request: VNRecognizeTextRequest = {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["ja"]
        return request
    }()
    
    private var isProcessing = false
    private var frameCount = 0
    private let processEveryNthFrame: Int
    
    private let jpFilter = JPFilter()
    
    init(processEveryNthFrame: Int = 10) {
        self.processEveryNthFrame = processEveryNthFrame
    }

    func performTextRecognition(on data: Data, inRegion regionOfInterest: CGRect? = nil, completion: @escaping ([TextRecognitionData]?) -> Void) {
        frameCount += 1
        guard frameCount % processEveryNthFrame == 0, !isProcessing else {
            completion(nil)
            return
        }

        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            defer { self.isProcessing = false }
            
            let requestHandler = VNImageRequestHandler(data: data, options: [:])
            
            if let regionOfInterest {
                self.request.regionOfInterest = regionOfInterest
            }
            
            do {
                try requestHandler.perform([self.request])
                let result = self.recognizeTextHandler()
                DispatchQueue.main.async {
                    completion(result)
                }
            } catch {
                assert(true, "Failed to perform text recognition: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    private func recognizeTextHandler() -> [TextRecognitionData] {
        guard let observations = request.results else {
            assert(true, "No text recognized")
            return []
        }

        return observations.compactMap { observation in
            guard
                let recognizedText = observation.topCandidates(1).first?.string,
                jpFilter.containsOnlyJapaneseCharacters(recognizedText)
            else { return nil }

            let roiRect = self.request.regionOfInterest
            let normalizedBoundingBox = observation.boundingBox
            
            let absoluteBoundingBox = CGRect(
                x: roiRect.minX + normalizedBoundingBox.minX * roiRect.width,
                y: roiRect.minY + normalizedBoundingBox.minY * roiRect.height,
                width: normalizedBoundingBox.width * roiRect.width,
                height: normalizedBoundingBox.height * roiRect.height
            )
            
            return (text: recognizedText, bounds: absoluteBoundingBox)
        }
    }
}
