//
//  PiPlexApp.swift
//  PiPlex
//
//  Created by Косоруков Дмитро on 10/08/2024.
//

import SwiftUI
import AVFAudio

@main
struct PiPlexApp: App {
    
    private func requestPIPBackgroundMode() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .moviePlayback)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    init() {
        requestPIPBackgroundMode()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("App loaded")
                }
        }
    }
}
