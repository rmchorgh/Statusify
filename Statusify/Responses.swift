//
//  Responses.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/1/23.
//

import Foundation

struct CurrentlyPlaying: Codable {
    let album_art: String
    let artists: String
    let name: String
    let play_state: Bool
    let progress: UInt32
    let duration: UInt32
}
