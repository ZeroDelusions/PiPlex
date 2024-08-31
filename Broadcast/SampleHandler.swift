//
//  SampleHandler.swift
//  Broadcast
//
//  Created by Косоруков Дмитро on 10/08/2024.
//

import ReplayKit
import IOSurface
import MachO
import SurfaceMessage
import Aruco

class SampleHandler: RPBroadcastSampleHandler {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private var sharedMemory: UnsafeMutableRawPointer?
    private let sharedMemorySize = 1024 * 1024
    
    private let arucoDataModel: ArucoDataModel
    private let arucoRecognizer: ArucoRecognitionModel
    private var previousArucoMarkers: ArucoMarkersData = [:]
    private var previousPiPRect: CGRect?
    
    private let imageProcessor = ImageProcessorModel()
    
    private var lastProcessedTimestamp: Double = 0
    private let targetFrameInterval: Double = 1.0 / 10.0 // 10 fps
    
    override init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Failed to create MTLDevice")
        }
        self.device = device
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Failed to create command queue")
        }
        self.commandQueue = commandQueue
        self.arucoDataModel = ArucoDataModel(dictionaryId: 12, markerIds: [0, 1, 2, 3], sidePixels: 64)
        self.arucoRecognizer = ArucoRecognitionModel(dictionary: self.arucoDataModel.dictionary)
        
        super.init()
        
        initializeSharedMemory()
    }
    
    deinit {
        cleanupSharedMemory()
    }
    
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // Broadcast start logic can be implemented here if needed
    }
    
    override func broadcastPaused() {
        // Broadcast pause logic can be implemented here if needed
    }
    
    override func broadcastResumed() {
        // Broadcast resume logic can be implemented here if needed
    }
    
    override func broadcastFinished() {
        // Broadcast finish logic can be implemented here if needed
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video else { return }
        processVideoSampleBuffer(sampleBuffer)
    }
    
    private func processVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        let currentTimestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        guard currentTimestamp - lastProcessedTimestamp >= targetFrameInterval else { return }
        lastProcessedTimestamp = currentTimestamp
        
        guard let cgImage = convertSampleBufferToCGImage(sampleBuffer) else { return }
        
        guard let currentArucoMarkers = self.arucoRecognizer.detectMarkers(in: cgImage),
              let topLeftCorner = currentArucoMarkers[0] else { return }
        
        guard let previousTopLeftCorner = self.previousArucoMarkers[0] else {
            self.previousArucoMarkers = currentArucoMarkers
            return
        }
        
        let previousOrigin = previousTopLeftCorner[0]
        let currentOrigin = topLeftCorner[0]
        
        guard hypot(currentOrigin.x - previousOrigin.x, currentOrigin.y - previousOrigin.y) >= 1 else { return }
        
        guard let processingResult = self.imageProcessor.processFrame(cgImage: cgImage, markers: currentArucoMarkers, lastMarkers: self.previousArucoMarkers) else { return }
        
        self.previousArucoMarkers = currentArucoMarkers
        self.previousPiPRect = processingResult.pipRectangle
        
        guard let jpegData = UIImage(cgImage: processingResult.croppedCGImage).jpegData(compressionQuality: 0.5) else { return }
        
        let encodedData = encodeRectangleAndImageData(rectangle: processingResult.pipRectangle, imageData: jpegData)
        
        writeToSharedMemory(encodedData)
    }
    
    private func encodeRectangleAndImageData(rectangle: CGRect, imageData: Data) -> Data {
        var encodedData = Data()
        let rectValues = [rectangle.origin.x, rectangle.origin.y, rectangle.width, rectangle.height]
        encodedData.append(contentsOf: rectValues.withUnsafeBytes { Data($0) })
        encodedData.append(imageData)
        return encodedData
    }
    
    private func convertSampleBufferToCGImage(_ sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: [.useSoftwareRenderer: false])
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        return context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    private func initializeSharedMemory() {
        guard let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.PiPlex.shared") else {
            fatalError("App Group URL not found")
        }
        let sharedMemoryURL = appGroupURL.appendingPathComponent("SharedMemory")
        
        let fileDescriptor = open(sharedMemoryURL.path, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR)
        guard fileDescriptor != -1 else {
            fatalError("Failed to open shared memory file")
        }
        
        ftruncate(fileDescriptor, off_t(sharedMemorySize))
        
        sharedMemory = mmap(nil, sharedMemorySize, PROT_READ | PROT_WRITE, MAP_SHARED, fileDescriptor, 0)
        guard sharedMemory != MAP_FAILED else {
            fatalError("Failed to map shared memory")
        }
        
        close(fileDescriptor)
    }
    
    private func cleanupSharedMemory() {
        if let sharedMemory = sharedMemory {
            munmap(sharedMemory, sharedMemorySize)
        }
    }
    
    private func writeToSharedMemory(_ data: Data) {
        guard let sharedMemory = sharedMemory else { return }
        _ = data.withUnsafeBytes { source in
            memcpy(sharedMemory, source.baseAddress, min(data.count, sharedMemorySize))
        }
        
        /// Post a notification to inform other processes that new frame data is available
        let notificationName = "com.PiPlex.newFrameReady"
        let notification = CFNotificationName(notificationName as CFString)
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notification, nil, nil, true)
    }
}
