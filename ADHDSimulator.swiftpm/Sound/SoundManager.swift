//
//  File.swift
//  
//
//  Created by Gabriel Medeiros Martins on 23/02/24.
//

import Foundation
import AVFoundation

class SoundManager: ObservableObject {
    enum Sound {
        case click
        case song
        
        static private let clickFileNames: [String] = [
            "Minimalist1",
            "Minimalist2",
            "Minimalist3",
        ]
        
        var fileName: String {
            switch self {
            case .click:
                return Self.clickFileNames.randomElement()!
            case .song:
                return "Groovy-booty"
            }
        }
    }

    private var mainPlayer: AVAudioPlayer?
    private var soundEffectsPlayer: AVAudioPlayer?
    
    init() {
        play(.song)
    }
    
    func play(_ sound: Sound = .click) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "wav") else { return }
                    
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()

                DispatchQueue.main.sync {
                    if sound == .song {
                        player.volume = 0.12
                    }
                    
                    player.play()
                }
                
                switch sound {
                case .click:
                    self?.soundEffectsPlayer = player
                case .song:
                    self?.mainPlayer = player
                    self?.mainPlayer?.numberOfLoops = -1
                }
                
            } catch {
                print("Failed to play sound \(sound.fileName)")
            }
        }
    }
    
    func stop(_ main: Bool = true) {
        mainPlayer?.stop()
    }
}
