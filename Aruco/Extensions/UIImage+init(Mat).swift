//
//  UIImage+init(Mat).swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 19/08/2024.
//

import SwiftUI
import opencv2

extension UIImage {
    convenience init?(mat: Mat) {
        // Ensure the Mat is in the correct format (either grayscale or RGB)
        let matType = mat.type()
        let isGrayscale = matType == CvType.CV_8UC1
        let isRGB = matType == CvType.CV_8UC3
        
        if !isGrayscale && !isRGB {
            print("Unsupported cv::Mat type for conversion to UIImage.")
            return nil
        }
        
        let colorSpace = isGrayscale ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB()
        
        // Prepare image parameters
        let width = mat.cols()
        let height = mat.rows()
        let bytesPerRow = mat.step1()
        let bitmapInfo: CGBitmapInfo = isGrayscale ? [] : CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        // Create the context from the Mat data
        guard let context = CGContext(data: mat.dataPointer(),
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {
            print("Failed to create CGContext from cv::Mat.")
            return nil
        }
        
        // Create a CGImage from the context
        guard let cgImage = context.makeImage() else {
            print("Failed to create CGImage from CGContext.")
            return nil
        }
        
        // Initialize the UIImage from the CGImage
        self.init(cgImage: cgImage)
    }
}

