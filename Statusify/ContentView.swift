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
    let key = "BQCxakbs0px7ushj9dbWPjncd3AlWqv3Bj49hOVqtJHf3T2JwmNRSVjXgCVDL6oqHVRKEOzF5GKrdqrgamSvWM-K5tl4c08zKFb31O49FUIHYYmW6rPnHOMHy-99qzC-Q9aP0ld_L-HJD85x-U0vsOiYURYVj4VsLzcVjArZb5o6sOyn"
    
    @State var serviceRunning = false
    
    @State var content = ""
    
    @State var artist: String? = nil
    @State var title: String? = nil
    @State var url: URL? = nil
    @State var playing = false
    @State var remaining: UInt32? = nil
    
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
        }
        else {
            print("Starting")
            guard let res = try? safeShell("services", "restart", "spotifyd") else {
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
                url = sr.albumArt[1].image
                playing = sr.state
                remaining = (sr.duration - sr.progress) / 1000
                
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
                .frame(width: 300, height: 300)
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
                Button {
                    toggleService()
                } label: {
                    Text(serviceRunning ? "Turn Off" : "Turn On")
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
                    Image(systemName: playing ? "pause" : "play.fill")
                        .animation(.easeInOut, value: playing)
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
        .frame(width: 300, height: 300)
        .onAppear {
            isRunning()
        }
        .onReceive(timer) { _ in
            if remaining == 0 {
                remaining = nil
                getInformation()
            }
            else if remaining != nil {
                remaining! -= 1
            }
        }
    }
}
