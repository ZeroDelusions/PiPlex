//
//  ImageProcessorModel.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 11/08/2024.
//

import Foundation
import UIKit
import Aruco
import CoreGraphics

class ImageProcessorModel {
    private(set) var lastFrame: CGImage?

    func processFrame(cgImage inputImage: CGImage, markers: ArucoMarkersData, lastMarkers: ArucoMarkersData) -> (croppedCGImage: CGImage, pipRectangle: CGRect)? {
        guard
            let lastFrame = lastFrame,
            let pipRect = calculateCroppingRectangle(markers: markers),
            let context = createContext(for: inputImage),
            let croppedOuterImage = getCroppedOuterImage(cgImage: inputImage, pipRect: pipRect, context: context),
            let overlayedImage = overlayFrames(backgroundImage: lastFrame, overlayImage: croppedOuterImage, context: context)
        else {
            self.lastFrame = inputImage
            return nil
        }

        self.lastFrame = overlayedImage
        return (overlayedImage, pipRect)
    }

    // MARK: - Private Methods

    private func createContext(for image: CGImage) -> CGContext? {
        return CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: image.bitsPerComponent,
            bytesPerRow: 0,
            space: image.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    }

    private func cropImageToPiP(cgImage inputImage: CGImage, cropRectangle cropRect: CGRect) -> CGImage? {
        guard cropRect.intersects(CGRect(x: 0, y: 0, width: inputImage.width, height: inputImage.height)) else {
            return nil
        }
        return inputImage.cropping(to: cropRect)
    }

    private func getCroppedOuterImage(cgImage inputImage: CGImage, pipRect: CGRect, context: CGContext) -> CGImage? {
        let imageSize = CGSize(width: inputImage.width, height: inputImage.height)
        
        context.clear(CGRect(origin: .zero, size: imageSize))
        context.draw(inputImage, in: CGRect(origin: .zero, size: imageSize))
        
        let expandedRect = pipRect.insetBy(dx: -5 * (pipRect.width / 500), dy: -5 * (pipRect.height / 500))
        
        let flippedCropRect = CGRect(
            x: expandedRect.origin.x,
            y: imageSize.height - expandedRect.maxY,
            width: expandedRect.width,
            height: expandedRect.height
        )
        context.clear(flippedCropRect)
        
        return context.makeImage()
    }

    private func overlayFrames(backgroundImage: CGImage, overlayImage: CGImage, context: CGContext) -> CGImage? {
        let imageSize = CGSize(width: backgroundImage.width, height: backgroundImage.height)

        context.clear(CGRect(origin: .zero, size: imageSize))
        context.draw(backgroundImage, in: CGRect(origin: .zero, size: imageSize))
        context.draw(overlayImage, in: CGRect(origin: .zero, size: imageSize))

        return context.makeImage()
    }
    
    private func calculateCroppingRectangle(markers: ArucoMarkersData, lastMarkers: ArucoMarkersData) -> CGRect? {
        guard markers.count == 4,
              let topLeftMarker = markers[0],
              let bottomRightMarker = markers[2],
              let lastTopLeftMarker = lastMarkers[0],
              let lastBottomRightMarker = lastMarkers[2]
        else {
            print("Invalid Aruco marker count: \(markers.count)")
            return nil
        }
        
        var startX: CGFloat = topLeftMarker[0].x
        var startY: CGFloat = topLeftMarker[0].y
        var endX: CGFloat = bottomRightMarker[2].x
        var endY: CGFloat = bottomRightMarker[2].y
        
        if lastTopLeftMarker[0].x <= topLeftMarker[0].x { startX = lastTopLeftMarker[0].x }
        if lastTopLeftMarker[0].y <= topLeftMarker[0].y { startY = lastTopLeftMarker[0].y }
        if lastBottomRightMarker[2].x >= bottomRightMarker[2].x { endX = lastBottomRightMarker[2].x }
        if lastBottomRightMarker[2].y >= bottomRightMarker[2].y { endY = lastBottomRightMarker[2].y }

        let insetFactor: CGFloat = 20 / 500
        let cropRect = CGRect(
            x: startX - insetFactor * (bottomRightMarker[2].x - topLeftMarker[0].x),
            y: startY - insetFactor * (bottomRightMarker[2].y - topLeftMarker[0].y),
            width: endX - startX + 2 * insetFactor * (bottomRightMarker[2].x - topLeftMarker[0].x),
            height: endY - startY + 2 * insetFactor * (bottomRightMarker[2].y - topLeftMarker[0].y)
        )

        return cropRect
    }

    private func calculateCroppingRectangle(markers: ArucoMarkersData) -> CGRect? {
        guard markers.count == 4,
              let topLeftMarker = markers[0],
              let bottomRightMarker = markers[2]
        else {
            print("Invalid Aruco marker count: \(markers.count)")
            return nil
        }

        let start: CGPoint = topLeftMarker[0]
        let end: CGPoint = bottomRightMarker[2]

        let insetFactor: CGFloat = 20 / 500
        let cropRect = CGRect(
            x: start.x - insetFactor * (end.x - start.x),
            y: start.y - insetFactor * (end.y - start.y),
            width: end.x - start.x + 2 * insetFactor * (end.x - start.x),
            height: end.y - start.y + 2 * insetFactor * (end.y - start.y)
        )

        return cropRect
    }
}
