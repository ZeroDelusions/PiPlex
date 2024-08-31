//
//  Mat+toCGPointArray.swift
//  Aruco
//
//  Created by Косоруков Дмитро on 31/08/2024.
//

import Foundation
import opencv2

extension Mat {
    public func toCGPointArray() -> [CGPoint] {
        var points: [CGPoint] = []
        let rowCount = rows()
        let colCount = cols()
        
        for row in 0..<rowCount {
            for col in 0..<colCount {
                let value = get(row: row, col: col)
                if value.count == 2 {
                    let point = CGPoint(x: value[0], y: value[1])
                    points.append(point)
                }
            }
        }
        return points
    }
}
