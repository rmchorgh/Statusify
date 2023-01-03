//
//  ContentView.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/1/23.
//

import SwiftUI

struct ContentView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let spt = "https://api.spotify.com/v1/me/player/"
    @State var key = ""
    
    @State var serviceRunning = false
    
    @State var content = ""
    
    @State var devices: [(String, String)] = []
    @State var artist: String? = nil
    @State var title: String? = nil
    @State var url: URL? = nil
    @State var playing = false
    @State var remaining: UInt32? = nil
    
    @State var restart = 5
    
    func isRunning() {
        guard let res = try? brew("services") else {
            content = "Couldn't read Homebrew services"
            return
        }
        
        if res.contains("spotifyd started") {
            serviceRunning = true
            content = "Service running"
            getInformation()
        }
        else {
            content = "Service not running"
            toggleService()
        }
    }
    
    func toggleService() {
        if serviceRunning {
            print("Stopping")
            guard let res = try? brew("services", "stop", "spotifyd") else {
                content = "Stopping service failed."
                return
            }
            print(res)
            serviceRunning = false
        }
        else {
            print("Starting")
            guard let res = try? brew("services", "restart", "spotifyd") else {
                content = "Starting service failed."
                return
            }
            print(res)
            serviceRunning = true
        }
        getInformation()
        content = ""
    }
    
    func getInformation() {
        do {
            var cur = try requests(.current)
            print(cur)
            if cur.contains("The access token expired") {
                print("Getting new token.")
                _ = try keyServer()
                cur = try requests(.current)
            }
            
            let d = JSONDecoder()
            let v = try d.decode(CurrentlyPlaying.self, from: cur.data(using: .utf8)!)
            artist = v.artists
            title = v.name
            url = URL(string: v.album_art)
            playing = v.play_state
            remaining = (v.duration - v.progress) / 1000
            content = title!
        }
        catch {
            print(error)
        }
    }
    
    @discardableResult
    func mediaControl(_ dir: StatusifyRequest) -> Bool {
        do {
            var mc = try requests(dir)
            print(mc)
            if mc.contains("The access token expired") {
                print("Getting new token.")
                _ = try keyServer()
                mc = try requests(dir)
            }
            getInformation()
            return true
        }
        catch {
            print(error)
            return false
        }
    }
    
    let windowDim = 300.0
    @ViewBuilder var albumArt: some View {
        if url != nil {
            AsyncImage(url: url)
                .aspectRatio(contentMode: .fit)
                .frame(width: windowDim, height: windowDim)
                .overlay {
                    LinearGradient(colors: [.black.opacity(0.75), .black.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                }
        }
        else {
            EmptyView()
        }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(content)
                    if artist != nil {
                        Text(artist!)
                            .font(.caption2)
                    }
                }
                Spacer()
                
                if serviceRunning {
                    Image(systemName: "stop.fill")
                        .button()
                        .animation(.easeInOut, value: serviceRunning)
                        .onTapGesture {
                            toggleService()
                        }
                }
                
            }
            Spacer()
            HStack {
                Image(systemName: "backward.fill")
                    .button()
                    .onTapGesture {
                        mediaControl(.prev)
                    }
                
                Image(systemName: playing ? "pause.fill" : "play.fill")
                    .button(5)
                    .animation(.easeInOut, value: playing)
                    .onTapGesture {
                        if playing {
                            if mediaControl(.pause) {
                                playing = false
                            }
                        }
                        else {
                            if mediaControl(.play) {
                                playing = true
                            }
                        }
                    }
                
                Image(systemName: "forward.fill")
                    .button()
                    .onTapGesture {
                        mediaControl(.next)
                    }
            }
        }
        .padding()
        .background(albumArt)
        .frame(width: 300, height: 300)
        .onAppear {
            isRunning()
        }
        .onReceive(timer) { _ in
            if remaining == 0 {
                remaining = nil
                getInformation()
            }
            else if remaining != nil && playing {
                remaining! -= 1
            }
        }
    }
}

extension Image {
    func button(_ buttonDim: CGFloat = 10.0) -> some View {
        let def = 10.0
        return self
            .resizable()
            .foregroundColor(.black)
            .frame(width: buttonDim == def ? def : def + buttonDim, height: buttonDim == def ? def : def + buttonDim)
            .padding(8)
            .background {
                Color.white
            }
            .clipShape(Circle())
    }
}
