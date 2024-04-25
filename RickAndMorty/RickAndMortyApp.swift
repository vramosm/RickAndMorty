//
//  RickAndMortyApp.swift
//  RickAndMorty
//
//  Created by Victor Ramos on 22/4/24.
//

import SwiftUI

@main
struct RickAndMortyApp: App {
    @StateObject var api = Api()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(api)
        }
    }
}
