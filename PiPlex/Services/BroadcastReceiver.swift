//
//  IOSurfaceReceiver.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 22/08/2024.
//

import Foundation
import UIKit

class BroadcastReceiver: ObservableObject {
    @Published var receivedRect: CGRect?
    @Published var receivedImageData: Data?
    
    private var memoryMap: UnsafeMutableRawPointer?
    private let memorySize = 1024 * 1024

    init() {
        /// Subscribe to the Darwin notification for new frames
        let notificationName = "com.PiPlex.newFrameReady" as CFString
        let callback: CFNotificationCallback = { center, observer, name, object, userInfo in
            guard let observer = observer else { return }
            let imageModel = Unmanaged<BroadcastReceiver>.fromOpaque(observer).takeUnretainedValue()
            imageModel.handleNewFrame()
        }
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), Unmanaged.passUnretained(self).toOpaque(), callback, notificationName, nil, .deliverImmediately)
        
        setupMemoryMapping()
    }
    
    deinit {
        /// Remove the notification observer
        let notificationName = CFNotificationName("com.PiPlex.newFrameReady" as CFString)
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), nil, notificationName, nil)
        
        cleanupMemoryMapping()
    }
    
    private func setupMemoryMapping() {
        guard let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.PiPlex.shared") else {
            fatalError("App Group URL not found")
        }
        let dataFileURL = appGroupURL.appendingPathComponent("SharedMemory")

        let fd = open(dataFileURL.path, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR)
        guard fd != -1 else {
            fatalError("Failed to open shared memory file")
        }

        ftruncate(fd, off_t(memorySize))
        
        memoryMap = mmap(nil, memorySize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)
        guard memoryMap != MAP_FAILED else {
            fatalError("Failed to map shared memory")
        }
        
        close(fd)
    }
    
    private func cleanupMemoryMapping() {
        if let memoryMap = memoryMap {
            munmap(memoryMap, memorySize)
        }
    }
    
    private func handleNewFrame() {
        if let (rect, imageData) = getDecodedDataFromSharedMemory() {
            DispatchQueue.main.async {
                self.receivedRect = rect
                self.receivedImageData = imageData
            }
        } else {
            fatalError("Error decoding data from shared memory.")
        }
    }
    
    private func getDecodedDataFromSharedMemory() -> (CGRect, Data)? {
        guard let memoryMap = memoryMap else { return nil }
        
        let encodedData = Data(bytes: memoryMap, count: memorySize)
        
        return decodeImageRectAndData(from: encodedData)
    }

    private func decodeImageRectAndData(from encodedData: Data) -> (CGRect, Data)? {
        let rectSize = MemoryLayout<CGFloat>.size * 4
        guard encodedData.count > rectSize else { return nil }

        let rectArray = encodedData.subdata(in: 0..<rectSize).withUnsafeBytes {
            Array($0.bindMemory(to: CGFloat.self))
        }
        
        let rect = CGRect(x: rectArray[0], y: rectArray[1], width: rectArray[2], height: rectArray[3])
        
        let imageData = encodedData.subdata(in: rectSize..<encodedData.count)
        
        return (rect, imageData)
    }
}
