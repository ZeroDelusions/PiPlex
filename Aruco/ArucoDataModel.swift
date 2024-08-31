//
//  ArucoDataModel.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 19/08/2024.
//

import Foundation
import opencv2
import SwiftUI

public class ArucoDataModel {
    public private(set) var dictionary: opencv2.Dictionary
    public private(set) var markers: [MarkerQuadrant: UIImage] = [:]
    
    public init(dictionaryId: Int32, markerIds: [Int32], sidePixels: Int32) {
        self.dictionary = opencv2.Dictionary(id: dictionaryId)
        self.markers = createArucoMarkers(markerIds: markerIds, sidePixels: sidePixels)
    }
    
    public enum MarkerQuadrant: Int, CaseIterable {
        case topLeft, topRight, bottomRight, bottomLeft
    }
    
    public func setDictionary(_ dict: opencv2.Dictionary) {
        self.dictionary = dict
    }
    
    public func setDictionary(id: Int32) {
        self.dictionary = opencv2.Dictionary(id: id)
    }
    
    public func setMarkers(ids: [Int32], sidePixels: Int32) {
        self.markers = createArucoMarkers(markerIds: ids, sidePixels: sidePixels)
    }
    
    private func createArucoMarkers(markerIds: [Int32], sidePixels: Int32) -> [MarkerQuadrant: UIImage] {
        var markers: [MarkerQuadrant: UIImage] = [:]
        
        for (index, id) in markerIds.enumerated() {
            let markerImage = Mat.zeros(sidePixels, cols: sidePixels, type: CvType.CV_8UC1)
            Objdetect.generateImageMarker(dictionary: self.dictionary, id: id, sidePixels: sidePixels, img: markerImage, borderBits: 1)
            
            if let uiImg = UIImage(mat: markerImage), let quadrant = MarkerQuadrant(rawValue: index) {
                markers[quadrant] = uiImg
            } else {
                return [:]
            }
        }

        return markers
    }
}
