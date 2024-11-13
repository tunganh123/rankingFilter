//
//  Audio_manager.swift
//  LouisPod
//
//  Created by TungAnh on 24/5/24.
//

import AVFoundation
import Foundation

public class AudioManager: NSObject {
    public static let shared = AudioManager()
    var audioPlayers: [String: AVAudioPlayer] = [:]
    var audio_background = "nhạc nền"

    override private init() {}

    func initializeAudio(fileName: String, fileType: String, identifier: String) {
        // Kiểm tra xem audioPlayer đã tồn tại chưa
        if audioPlayers[identifier] != nil {
            return
        }

        if let audioFilePath = Bundle.main.path(forResource: fileName, ofType: fileType) {
            let audioFileUrl = URL(fileURLWithPath: audioFilePath)
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
                audioPlayer.delegate = self // Set delegate to self
                audioPlayers[identifier] = audioPlayer
                audioPlayer.prepareToPlay()
            } catch {
                print("Error: Could not load audio file for \(identifier).")
            }
        } else {
            print("Error: Could not find audio file for \(identifier).")
        }
    }

    func playAudio(identifier: String) {
        // check_audio là nhạc nền vào app, nhạc nền
        // check_SoundEffect là nhạc button, countdowt, true, false, chuẩn bị hết giờ
        let check_audio_permiss = (UserDefaults.standard.object(forKey: "check_audio"))
        if check_audio_permiss != nil, (check_audio_permiss as! Bool) == true {
            if identifier == "nhạc nền vào app" || identifier == "nhạc nền" {
                audioPlayers[identifier]?.play()
            }
        }
        let check_SoundEffect_permiss = (UserDefaults.standard.object(forKey: "check_SoundEffect"))
        if check_SoundEffect_permiss != nil, (check_SoundEffect_permiss as! Bool) == true {
            if identifier == "click button" || identifier == "đáp án đúng" || identifier == "đáp án sai" || identifier == "đếm ngược 3s" || identifier == "chuẩn bị hết giờ" {
                audioPlayers[identifier]?.play()
            }
        }
    }

    func stopAudio(identifier: String) {
        audioPlayers[identifier]?.stop()
    }

    func removeAudio(identifier: String) {
        guard let player = audioPlayers[identifier] else {
            print("Audio player not found for identifier: \(identifier)")
            return
        }
        // Stop the player if it is currently playing
        if player.isPlaying {
            player.stop()
        }
        // Remove the player from the dictionary
        audioPlayers.removeValue(forKey: identifier)
    }

    func setVolume(_ volume: Float, identifier: String) {
        guard let player = audioPlayers[identifier] else {
            print("Audio player not found for identifier: \(identifier)")
            return
        }

        let wasPlaying = player.isPlaying
        player.volume = volume
        // If the volume is set to a value greater than 0 and the player was not playing, start playing it
        if volume > 0 && !wasPlaying {
            player.play()
        }
    }

    func stopAllAudio() {
        for player in audioPlayers.values {
            player.stop()
        }
    }

    func setVolumeForAll(_ volume: Float) {
        for player in audioPlayers.values {
            player.volume = volume
        }
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Phát lại âm thanh nếu cần
        for (identifier, audioPlayer) in audioPlayers {
            if identifier == "nhạc nền" {
                // Phát lại âm thanh cho đối tượng đã hoàn thành phát
                playAudio(identifier: identifier)
                break
            }
        }
    }
}
