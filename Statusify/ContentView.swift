//
//  ContentView.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/1/23.
//

import SwiftUI

struct ContentView: View {
    let on = "bolt.fill"
    let off = "bolt.slash"
    
    let spt = "https://api.spotify.com/v1/me/player/"
    let key = "BQAGGrlxfFNJJ3a3kIuMXfun8Q3Va7FVtb30d5Qj3b2I18XJ17QROFK8QVSBpaghHJCG_A5vk9ekHd2DkzVt-CN9Fr-9ukSIBJ3HAxBWb8ipWJxK0CUKhpeX2QokbGlf_87-geDmqitQaTANmPpnn7v7P_hAcZ_Z6Wq65Lx2x-y-zUyz"
    
    @State var serviceRunning = false
    
    @State var content = ""
    
    @State var artist: String? = nil
    @State var title: String? = nil
    @State var url: URL? = nil
    @State var playing = false
    
    func isRunning() {
        print("isRunning:")
        guard let res = try? safeShell("services") else {
            content = "Couldn't read Homebrew services"
            return
        }
        
        if res.contains("spotifyd") {
            serviceRunning = true
            content = "Service running"
            getInformation()
        }
        else {
            content = "Service not running"
        }
    }
    
    func toggleService() {
        if serviceRunning {
            print("Stopping")
            guard let res = try? safeShell("services", "stop", "spotifyd") else {
                content = "Stopping service failed."
                return
            }
            print(res)
            serviceRunning = false
            content = ""
            return
        }
        
        print("Starting")
        guard let res = try? safeShell("services", "restart", "spotifyd") else {
            content = "Starting service failed."
            return
        }
        print(res)
        serviceRunning = true
        getInformation(true)
        content = ""
    }
    
    func getInformation(_ test: Bool) {
        if test {
            artist = "Maroon 5"
            title = "Harder To Breathe"
            url = URL(string: "https://i.scdn.co/image/ab67616d0000b27370150b6fe62a820a13b78bb6")
        }
        else {
            getInformation()
        }
        
        if let title = title, let artist = artist {
            StatusBarController.updateSong("\(title) - \(artist)")
        }
    }
    
    func getInformation() {
        var req = URLRequest(url: URL(string: "\(spt)currently-playing")!)
        req.httpMethod = "GET"
        req.allHTTPHeaderFields = ["Authorization": "Bearer \(key)"]
        
        let task = URLSession.shared.dataTask(with: req) { data, res, err in
            if let err = err {
                print("Couldn't get player information.")
                print(err)
                return
            }
            
            guard let res = res as? HTTPURLResponse, (200...299).contains(res.statusCode) else {
                if res == nil {
                    print("No result from Spotify.")
                }
                else {
                    print("Spotify returned code \((res as! HTTPURLResponse).statusCode).")
                    print(String(data: data!, encoding: .utf8)!)
                    
                }
                return
            }
            
            guard let data = data  else {
                print("Couldn't interpret data as non-nil.")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                let sr = try SpotifyResponse(json!)
                
                artist = sr.artists.map({ a in a.name }).joined(separator: ", ")
                title = sr.name
                url = sr.albumArt.first!.image
                playing = sr.state
                
                content = title!
            }
            catch {
                print("Couldn't decode JSON.")
                print(error)
            }
            
        }
        
        task.resume()
    }
    
    func backward() {
        mediaControl("previous", "POST")
    }
    
    func play() {
        mediaControl("play", "PUT")
        playing = true
    }
    
    func pause() {
        mediaControl("pause", "PUT")
        playing = false
    }
    
    func forward() {
        mediaControl("next", "POST")
    }
    
    func mediaControl(_ dir: String, _ method: String) {
        var req = URLRequest(url: URL(string: "\(spt)\(dir)")!)
        req.httpMethod = method
        req.allHTTPHeaderFields = ["Authorization": "Bearer \(key)"]
        
        let task = URLSession.shared.dataTask(with: req) { data, res, err in
            if let err = err {
                print("Couldn't get player to \(dir).")
                print(err)
                return
            }
            
            guard let res = res as? HTTPURLResponse, (200...299).contains(res.statusCode) else {
                if res == nil {
                    print("No result from Spotify.")
                }
                else {
                    print("Spotify returned code \((res as! HTTPURLResponse).statusCode).")
                    print(String(data: data!, encoding: .utf8)!)
                }
                return
            }
            
            getInformation()
        }
        
        task.resume()
    }
    
    @ViewBuilder var albumArt: some View {
        if url != nil {
            AsyncImage(url: url)
                .aspectRatio(contentMode: .fit)
                .overlay {
                    LinearGradient(colors: [.black.opacity(0.75), .black.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                }
                .frame(width: 200, height: 200)
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
                Button {
                    toggleService()
                } label: {
                    Image(systemName: serviceRunning ? off : on)
                        .animation(.easeInOut, value: serviceRunning)
                }
            }
            Spacer()
            HStack {
                Button {
                    backward()
                } label: {
                    Image(systemName: "backward")
                }
                
                Button {
                    if playing {
                        pause()
                    }
                    else {
                        play()
                    }
                } label: {
                    Image(systemName: "play.fill")
                }
                
                Button {
                    forward()
                } label: {
                    Image(systemName: "forward")
                }
            }
        }
        .padding()
        .background(albumArt)
        .frame(width: 200, height: 200)
        .onAppear {
            isRunning()
        }
    }
}
