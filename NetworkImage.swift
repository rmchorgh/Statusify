//
//  NetworkImage.swift
//  Statusify
//
//  Created by Richard McHorgh on 1/1/23.
//

import SwiftUI

struct NetworkImage: View {
    var body: some View {
        AsyncImage(url: URL(string: "https://i.scdn.co/image/ab67616d00001e024c88e268c9dc19f79ccdbb97"))
    }
}
