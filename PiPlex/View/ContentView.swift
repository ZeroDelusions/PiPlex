//
//  ContentView.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 10/08/2024.
//

import SwiftUI
import AVKit
import opencv2
import UIKit



struct ContentView: View {
    @State private var isPiPActive = false
    @State private var pipSize: CGSize = .zero
    
    @StateObject private var broadcastCoordinator: BroadcastCoordinatorViewModel
    init() {
        _broadcastCoordinator = StateObject(wrappedValue: BroadcastCoordinatorViewModel())
    }

    var body: some View {
        ZStack {
            PiPViewRepresentable(isActive: $isPiPActive, broadcastCoordinator: _broadcastCoordinator)
                .opacity(0)
                .frame(width: 500, height: 500)
            
            Button("Launch PiP") {
                isPiPActive.toggle()
            }

        }
    }
}

//struct ContentView: View {
////    @State var pipi = false
////    @State var date = Date()
//    @StateObject private var broadcastCoordinator: BroadcastCoordinator
//    @State var isPipi = true
//
//    init() {
//        _broadcastCoordinator = StateObject(wrappedValue: BroadcastCoordinator())
//    }
//
//    var body: some View {
////        Text("\(date)")
////            .frame(width: 200)
////            .foregroundStyle(.white)
////            .pipify(isPresented: $pipi)
////
////
////        Button("Pipi") {
////            pipi.toggle()
////        }
////        ZStack {
////
////
////
////            ZStack {
////                Color.white.frame(width: 100, height: 100)
//////                if let broadcastData = broadcastCoordinator.broadcastData, let uiImg = UIImage(data: broadcastData) {
//////                    Image(uiImage: uiImg)
//////
//////                }
////            }
////            .pipify(isPresented: $isPipi)
////            Button("Pipi") {
////                isPipi.toggle()
////            }
////        }
//        Button("F") {
////            guard let pipWindow = UIApplication.shared.windows.first else {
////                print("no PiP window")
////                return
////            }
////            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
////
////                    // Assuming the window occupies the entire screen in normal mode
////                    let screenFrame = pipWindow.screen.bounds
////                    let windowFrame = pipWindow.frame
////
////                    // Calculate the window's position relative to the screen
////                    let globalOrigin = window.convert(windowFrame.origin, to: nil)
////
////                    print("Window's global position: \(globalOrigin)")
////
////            }
//
//
//        }
//
//        VStack {
//            Text(broadcastCoordinator.recognizedText)
//            Spacer()
//        }
//        .padding()
//        .onAppear {
//            broadcastCoordinator.start()
//        }
//        .onDisappear {
//            broadcastCoordinator.stop()
//        }
//    }
//}

#Preview {
    ContentView()
}
