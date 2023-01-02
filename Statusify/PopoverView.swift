//
//  PopoverView.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/1/23.
//

import SwiftUI

struct PopoverView: View {
    let on = "bolt.fill"
    let off = "bolt.slash"
    
    @State var serviceRunning = false
    
    @State var hovered = 0
    @State var content = ""
    
    @State var artist: String? = nil
    @State var title: String? = nil
    @State var url: URL? = nil
    
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
        getInformation()
        content = ""
    }
    
    func getInformation() {
        let spt = "https://api.spotify.com/v1/me/player/currently-playing"
        let key = "BQDd5-FonMbHe9pfnswfqpq01awVtKNAaCAPmjVTgYGkjJIn4HF6kVikWHGXRxPsRw0Vfkws4s282K4dbMWKdNNAh4yYSUs9FCLOBnTYIR1a2hvhCdZXxZsOk_6SNWYx2t7IqLfNbYtGDUi6CTK3qzMV1fOz460VFAcEz4dsQVie1zo"
        
        var req = URLRequest(url: URL(string: spt)!)
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
                url = sr.albumArt.last!.image
                
                content = artist!
            }
            catch {
                print("Couldn't decode JSON.")
                print(error)
//                print(String(data: data, encoding: .utf8)!)
            }
            
        }
        
        task.resume()
    }
    
    func backward() {
        
    }
    
    func play() {
        
    }
    
    func forward() {
        
    }
    
    @ViewBuilder var albumArt: some View {
        if url != nil {
            AsyncImage(url: url)
        }
        else {
            EmptyView()
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(content)
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
                    play()
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
        .frame(width: 200, height: 200)
        .background(albumArt)
        .onAppear {
            isRunning()
        }
    }
}
