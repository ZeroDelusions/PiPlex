//
//  PiPViewRepresentable.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 20/08/2024.
//

import SwiftUI
import UIPiPView
import AVKit
import Aruco

//protocol PiPSizeDelegate: AnyObject {
//    func didTransitionToRenderSize(_ newSize: CGSize)
//}
//
//// MARK: - CustomPiPView
//
//class CustomPiPView: UIPiPView {
//    weak var sizeDelegate: PiPSizeDelegate?
//
//    override func pictureInPictureController(
//        _ pictureInPictureController: AVPictureInPictureController,
//        didTransitionToRenderSize newRenderSize: CMVideoDimensions
//    ) {
//        let newSize = CGSize(width: CGFloat(newRenderSize.width), height: CGFloat(newRenderSize.height))
//        sizeDelegate?.didTransitionToRenderSize(newSize)
//    }
//}
//
//// MARK: - Coordinator
//
//class PiPViewCoordinator: NSObject, PiPSizeDelegate {
//    private let broadcastCoordinator: BroadcastCoordinatorViewModel
//
//    init(broadcastCoordinator: BroadcastCoordinatorViewModel) {
//        self.broadcastCoordinator = broadcastCoordinator
//    }
//
//    func didTransitionToRenderSize(_ newSize: CGSize) {
//        self.broadcastCoordinator.setPiPSize(newSize)
//    }
//}

//extension Array where Element == (text: String, boundingBox: CGRect) {
//    static func !=(lhs: [(text: String, boundingBox: CGRect)], rhs: [(text: String, boundingBox: CGRect)]) -> Bool {
//        guard lhs.count == rhs.count else { return true }
//        
//        for (index, element) in lhs.enumerated() {
//            if element.text != rhs[index].text || element.boundingBox != rhs[index].boundingBox {
//                return true
//            }
//        }
//        
//        return false
//    }
//}


// MARK: - PiPViewRepresentable

struct PiPViewRepresentable: UIViewRepresentable {
    @Binding var isActive: Bool
    @StateObject var broadcastCoordinator: BroadcastCoordinatorViewModel
    
    private let pipView = UIPiPView()
    private var arucoMarkerBorderWidth: CGFloat = 4
    private var backgroundImageView: UIImageView = UIImageView()
    private var textView: UIView = UIView()
    private let containerView = UIView()

    init(isActive: Binding<Bool>, broadcastCoordinator: StateObject<BroadcastCoordinatorViewModel>) {
        self._isActive = isActive
        self._broadcastCoordinator = broadcastCoordinator
    }

    func makeUIView(context: Context) -> UIPiPView {
        /// Background Image View
        backgroundImageView.contentMode = .topLeft
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = true
        containerView.addSubview(backgroundImageView)

        /// Text View
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.contentMode = .topLeft
        containerView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        pipView.addSubview(containerView)

        setupMarkers(in: pipView)
        return pipView
    }

    func updateUIView(_ uiView: UIPiPView, context: Context) {
        self.togglePiP(uiView, context: context)
        context.coordinator.updateUIPiPView()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject {
        private var parent: PiPViewRepresentable
        private var lastUpdatedText: [any ProcessedSentence] = []
        private var lastBackgroundImageOrigin: CGPoint?
        private var interpolationTimer: Timer?

        init(_ parent: PiPViewRepresentable) {
            self.parent = parent
            super.init()
        }

        func startPip() {
            self.parent.pipView.startPictureInPictureWithManualCallRender()
        }

        func stopPip() {
            self.parent.pipView.stopPictureInPicture()
        }

        func updateUIPiPView() {
            self.updateTextView()
            self.updateBackgroundImage()
        }

        private func updateBackgroundImage() {
            guard
                let newImage = self.parent.broadcastCoordinator.croppedImage,
                let newRect = self.parent.broadcastCoordinator.croppedImageRect
            else { return }

            self.parent.backgroundImageView.image = newImage

            // Calculate the scaling factors
            let scaleFactor = 500 / newRect.width

            self.parent.containerView.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)

            self.startInterpolation(to: CGPoint(x: -newRect.origin.x * scaleFactor, y: -newRect.origin.y * scaleFactor), scaleFactor: scaleFactor)
        }


        
        private func startInterpolation(to newMarkerPosition: CGPoint, scaleFactor: CGFloat) {
            interpolationTimer?.invalidate()

            let currentPosition = parent.containerView.frame.origin

            let deltaX = newMarkerPosition.x - currentPosition.x
            let deltaY = newMarkerPosition.y - currentPosition.y

            let animationDuration: TimeInterval = 0.1
            let frameRate: TimeInterval = 1.0 / 60.0
            let steps = Int(animationDuration / frameRate)
            let stepX = deltaX / CGFloat(steps)
            let stepY = deltaY / CGFloat(steps)

            var currentStep = 0

            interpolationTimer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { timer in
                guard currentStep <= steps else {
                    timer.invalidate()
                    self.parent.containerView.frame.origin = newMarkerPosition
                    return
                }

                let newX = currentPosition.x + CGFloat(currentStep) * stepX
                let newY = currentPosition.y + CGFloat(currentStep) * stepY
                self.parent.containerView.frame.origin = CGPoint(x: newX, y: newY)
                
                self.parent.pipView.render()

                currentStep += 1
            }
        }

        private func updateTextView() {
            
            if areSentencesEqual(self.parent.broadcastCoordinator.recognizedText, self.lastUpdatedText) {
                self.lastUpdatedText = self.parent.broadcastCoordinator.recognizedText
                return
            }
            
            self.parent.textView.subviews.forEach({ $0.removeFromSuperview() })
            
            for sentence in parent.broadcastCoordinator.recognizedText {
                
                let attributedJapaneseString = NSMutableAttributedString()
                let attributedMeaningsString = NSMutableAttributedString()
                let bbox = sentence.bounds
                
                sentence.words.forEach { word in
                    guard let firstEntry = word.dictionaryEntries.first else { return }
                    let attribute: [NSAttributedString.Key: Any] = [.backgroundColor: word.color]
                    
                    
                    let japanese = NSMutableAttributedString(string: word.base)
                    japanese.addAttributes(attribute, range: NSRange(location: 0, length: japanese.length))
                    attributedJapaneseString.append(japanese)
                    
                    
                    if word.partOfSpeech != .particle {
                        let meaning = NSMutableAttributedString(string: firstEntry.meanings[0] + " ")
                        meaning.addAttributes(attribute, range: NSRange(location: 0, length: meaning.length))
                        attributedMeaningsString.append(meaning)
                    }
                }
                
                let japaneseLabel = UILabel()
                japaneseLabel.attributedText = attributedJapaneseString
                japaneseLabel.textColor = .white
                
                guard let pipViewSize = parent.backgroundImageView.image?.size else { return }
                let japaneseLabelFrame = CGRect(
                    x: bbox.origin.x * pipViewSize.width,
                    y: (1 - bbox.origin.y - bbox.height) * pipViewSize.height,
                    width: bbox.width * pipViewSize.width,
                    height: bbox.height * pipViewSize.height
                )
                japaneseLabel.frame = japaneseLabelFrame
                
                let sizedFont = min(japaneseLabelFrame.width, japaneseLabelFrame.height)
                japaneseLabel.font = UIFont.systemFont(ofSize: sizedFont)
                japaneseLabel.sizeToFit()
                parent.textView.addSubview(japaneseLabel)
                
                
                let meaningLabel = UILabel()
                meaningLabel.attributedText = attributedMeaningsString
                meaningLabel.textColor = .white
                
                let meaningLabelFrame = japaneseLabel.frame.offsetBy(dx: 0, dy: 40)
                meaningLabel.frame = meaningLabelFrame
                
                meaningLabel.font = UIFont.systemFont(ofSize: sizedFont)
                meaningLabel.sizeToFit()
                parent.textView.addSubview(meaningLabel)
                
                
            }
        }
    }

    
    private func togglePiP(_ pipView: UIPiPView, context: Context) {
        if self.isActive {
            context.coordinator.startPip()
        } else {
            context.coordinator.stopPip()
        }
    }

    private func setupMarkers(in view: UIView) {
        ArucoDataModel.MarkerQuadrant.allCases.forEach { quadrant in
            if let image = broadcastCoordinator.arucoMarkers[quadrant] {
                let marker = createMarkerView(with: image)
                view.addSubview(marker)
                positionMarker(marker, in: view, at: quadrant)
            }
        }
    }

    private func createMarkerView(with image: UIImage?) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.layer.borderWidth = self.arucoMarkerBorderWidth
        borderView.layer.masksToBounds = true
        containerView.addSubview(borderView)

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        borderView.addSubview(imageView)

        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            borderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            borderView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: self.arucoMarkerBorderWidth),
            imageView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -self.arucoMarkerBorderWidth),
            imageView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: self.arucoMarkerBorderWidth),
            imageView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -self.arucoMarkerBorderWidth)
        ])

        return containerView
    }
    private func positionMarker(_ marker: UIView, in view: UIView, at quadrant: ArucoDataModel.MarkerQuadrant) {
        let padding: CGFloat = 15
        let constraints: [NSLayoutConstraint]

        switch quadrant {
        case .topLeft:
            constraints = [
                marker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
                marker.topAnchor.constraint(equalTo: view.topAnchor, constant: padding)
            ]
        case .topRight:
            constraints = [
                marker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
                marker.topAnchor.constraint(equalTo: view.topAnchor, constant: padding)
            ]
        case .bottomLeft:
            constraints = [
                marker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
                marker.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding)
            ]
        case .bottomRight:
            constraints = [
                marker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
                marker.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding)
            ]
        @unknown default:
            fatalError("Only 4 quadrants are possible.")
        }

        NSLayoutConstraint.activate(constraints)
    }
}
