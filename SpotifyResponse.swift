//
//  SpotifyResponse.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/1/23.
//

import Foundation

struct SpotifyResponse: Decodable {
    let albumArt: [AlbumArt]
    let artists: [Artist]
    let name: String
    let state: Bool
    let progress: UInt32
    let duration: UInt32
    
    struct AlbumArt: Decodable {
        let image: URL
        
        enum CodingKeys: String, CodingKey {
            case image = "url"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Self.CodingKeys.self)
            image = URL(string: try container.decode(String.self, forKey: .image))!
        }
    }
    
    struct Artist: Decodable {
        let name: String
    }
    
    enum CodingKeys: String, CodingKey {
        case albumArt = "item.album.images"
        case artists = "item.artists"
        case name = "item.name"
        case state = "is_playing"
        case progress = "progress_ms"
        case duration = "item.duration_ms"
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Self.CodingKeys.self)
        
        albumArt = try c.decode(Array<Self.AlbumArt>.self, forKey: .albumArt)
        artists = try c.decode(Array<Self.Artist>.self, forKey: .artists)
        name = try c.decode(String.self, forKey: .name)
        state = try c.decode(Bool.self, forKey: .state)
        progress = try c.decode(UInt32.self, forKey: .progress)
        duration = try c.decode(UInt32.self, forKey: .duration)
    }
    
    init(
}
