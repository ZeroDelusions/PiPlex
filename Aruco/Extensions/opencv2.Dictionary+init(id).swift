//
//  opencv2.Dictionary+init(id).swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 19/08/2024.
//

import Foundation
import opencv2

extension opencv2.Dictionary {
    convenience init(id: Int32) {
        let predefinedDict = Objdetect.getPredefinedDictionary(dict: id)
        self.init(bytesList: predefinedDict.bytesList, _markerSize: predefinedDict.markerSize, maxcorr: predefinedDict.maxCorrectionBits)
    }
}
