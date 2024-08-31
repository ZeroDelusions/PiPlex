//
//  BroadcastCoordinatorViewModel.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 10/08/2024.
//

import Foundation
import Combine
import SwiftUI
import Aruco
import IPADic
import Mecab_Swift

class BroadcastCoordinatorViewModel: ObservableObject {
    @Published private(set) var arucoMarkers: [ArucoDataModel.MarkerQuadrant: UIImage]
    @Published private(set) var pipSize: CGSize = CGSize(width: 500, height: 500)
    @Published private(set) var croppedImage: UIImage?

    private(set) var recognizedText: [any ProcessedSentence] = []
    private(set) var croppedImageRect: CGRect?
    
    private let broadcastReceiver = BroadcastReceiver()
    private let textRecognition = TextRecognitionModel()
    private let japaneseTokenization = JapaneseTokenizationModel()
    private let arucoData: ArucoDataModel
    private let dataProcessor: DataProcessorModel
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.arucoData = ArucoDataModel(dictionaryId: 12, markerIds: [0, 1, 2, 3], sidePixels: 48)
        self.arucoMarkers = arucoData.markers
        self.dataProcessor = DataProcessorModel(
            textRecognition: self.textRecognition,
            japaneseTokenization: self.japaneseTokenization
        )
        
        setupDataFlow()
    }
    
    private func setupDataFlow() {
        Publishers.CombineLatest(self.broadcastReceiver.$receivedImageData, self.broadcastReceiver.$receivedRect)
            .compactMap { data, rect -> (Data, CGRect)? in
                guard let data = data, let rect = rect else { return nil }
                return (data, rect)
            }
            .sink { [weak self] data, rect in
                guard let self = self, let uiImg = UIImage(data: data) else { return }
                self.dataProcessor.processData(data, in: rect, fullImageSize: uiImg.size)
                self.croppedImageRect = rect
                self.croppedImage = uiImg
            }
            .store(in: &cancellables)

        self.japaneseTokenization.$sentences
            .compactMap { $0 }
            .assign(to: \.recognizedText, on: self)
            .store(in: &cancellables)
    }
    
    func setPiPSize(_ size: CGSize) {
        self.pipSize = size
    }
}
