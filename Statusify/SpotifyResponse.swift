//
//  SpotifyResponse.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/1/23.
//

import Foundation

struct SpotifyResponse {
    let albumArt: [AlbumArt]
    let artists: [Artist]
    let name: String
    let state: Bool
    let progress: UInt32
    let duration: UInt32
    
    struct AlbumArt {
        let image: URL
    }
    
    struct Artist {
        let name: String
    }
    
    enum CodingKeys: CodingKey {
        case state, progress, name, duration, albumArt, artists
    }
    
    enum ResponseError: Error {
        case missing(CodingKeys), noItem, noAlbumImages, noArtists
    }
    
    init(_ json: [String: Any]) throws {
        guard let p = json["progress_ms"] as? UInt32 else {
            throw ResponseError.missing(.progress)
        }
        progress = p
        
        guard let s = json["is_playing"] as? Bool else {
            throw ResponseError.missing(.state)
        }
        state = s
        
        guard let item = json["item"] as? [String: Any] else {
            throw ResponseError.noItem
        }
        
        guard let n = item["name"] as? String else {
            throw ResponseError.missing(.name)
        }
        name = n
        
        guard let d = item["duration_ms"] as? UInt32 else {
            throw ResponseError.missing(.duration)
        }
        duration = d
        
        guard let al = item["album"] as? [String: Any], let ima = al["images"] as? [[String: Any]] else {
            print(item["album"]!)
            throw ResponseError.noAlbumImages
        }
        var im: [AlbumArt] = []
        for x in ima {
            guard let u = x["url"] as? String else {
                print(x)
                throw ResponseError.missing(.albumArt)
            }
            im.append(AlbumArt(image: URL(string: u)!))
        }
        albumArt = im
        
        guard let ar = item["artists"] as? [[String: Any]] else {
            print(item["artists"]!)
            throw ResponseError.noArtists
        }
        var art: [Artist] = []
        for x in ar {
            guard let a = x["name"] as? String else {
                throw ResponseError.missing(.artists)
            }
            art.append(Artist(name: a   ))
        }
        artists = art
    }
}
