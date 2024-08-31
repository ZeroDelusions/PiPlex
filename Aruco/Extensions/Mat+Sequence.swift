//
//  Mat+Sequence.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 19/08/2024.
//

import Foundation
import opencv2


extension Mat: Sequence {
    
    public func makeIterator() -> MatIterator {
        return MatIterator(mat: self)
    }
    
    public struct MatIterator: IteratorProtocol {
        private let mat: Mat
        private var currentRow: Int32 = 0
        private var currentCol: Int32 = 0
        
        public init(mat: Mat) {
            self.mat = mat
        }

        mutating public func next() -> [Double]? {
            guard currentRow < mat.rows(), currentCol < mat.cols() else {
                return nil
            }

            // Access the pixel value
            let value: [Double] = mat.get(row: currentRow, col: currentCol)

            // Move to the next pixel
            currentCol += 1
            if currentCol >= mat.cols() {
                currentCol = 0
                currentRow += 1
            }

            return value
        }
    }
}
