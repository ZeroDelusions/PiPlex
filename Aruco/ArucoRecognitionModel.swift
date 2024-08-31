//
//  ArucoRecognitionModel.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 18/08/2024.
//

import Combine
import opencv2

public typealias ArucoMarkersData = [Int: [CGPoint]]

public class ArucoRecognitionModel: ObservableObject {
    private let detector: opencv2.ArucoDetector
    public let dictionary: opencv2.Dictionary

    public init(dictionary: opencv2.Dictionary) {
        self.dictionary = dictionary
        self.detector = opencv2.ArucoDetector(dictionary: ())
        self.detector.setDictionary(dictionary: dictionary)
    }
    
    public func detectMarkers(in cgImage: CGImage) -> ArucoMarkersData?  {
        let imageMat = Mat(cgImage: cgImage)
        let markersCorners = NSMutableArray()
        let markersIds = Mat()
        
        detector.detectMarkers(image: imageMat, corners: markersCorners, ids: markersIds)
        return linkCornersWithIds(corners: markersCorners, ids: markersIds)
    }
    
    private func linkCornersWithIds(corners: NSMutableArray, ids: Mat) -> ArucoMarkersData {
        var markersData: ArucoMarkersData = [:]
        
        for (index, id) in ids.enumerated() {
            let unwrappedId = Int(id[0])
            guard let markerCorners = corners[index] as? Mat else { return [:] }
            markersData[unwrappedId] = markerCorners.toCGPointArray()
        }
        
        return markersData
    }
}
