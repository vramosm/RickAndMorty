//
//  CharacterListView.swift
//  RickAndMorty
//
//  Created by Victor Ramos on 22/4/24.
//

import SwiftUI
struct CharacterListView: View {
    @EnvironmentObject var api: Api
    @Binding var rootIsActive: Bool
    @State private var currentPageOfCharacters: [Character] = []
    
    // A Slider enabling the user to change the current page.
    var pageSlider: some View {
        Slider(
            value: Binding(
                get: { Double(api.filters.currentPage) },
                set: { api.filters.currentPage = Double(Int($0)) }
            ),
            in: 1...maxPages,
            step: 1
        )
        .padding()
        .onChange(of: api.filters.currentPage) { newValue in // When the value of currentPage changes, update the list.
            applyFilters()
            applyFilters()
        }
    }
    
    // Determines the maximum number of pages. If the user has filtered by episode, it uses that. Otherwise, it uses the total number of pages.
    var maxPages: Double {
        if !api.filters.episode.isEmpty {
            return Double(totalPages)
        } else {
            return Double(api.totalPages)
        }
    }
    
    // Calculates the total number of pages based on the count of episodeCharacters.
    var totalPages: Int {
        if api.episodeCharacters.count <= 20 {
            return 1
        } else {
            return (api.episodeCharacters.count + 19) / 20
        }
    }
    
    var body: some View {
        VStack {
            // Displays the characters in either a list or table, depending on whether the user has filtered by episode.
            if api.characters.isEmpty && currentPageOfCharacters.isEmpty {
                if let message = api.apiErrorMessage {
                    Text(message)
                } else {
                    Text("Loading...")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                }
            } else if api.episodeCharacters.isEmpty && api.characters.isEmpty {
                if let message = api.apiErrorMessage {
                    Text(message)
                } else {
                    Text("Loading...")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                }
            } else if api.episodeCharacters.isEmpty && !api.characters.isEmpty && !api.filters.episode.isEmpty {
                if let message = api.apiErrorMessage {
                    Text(message)
                } else {
                    Text("Loading...")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                }
            } else{
                if !api.filters.episode.isEmpty {
                    List {
                        ForEach(api.currentPageOfCharacters) { character in
                            NavigationLink(destination: DetailView(character: character, rootIsActive: $rootIsActive).environmentObject(api)) {
                                CharacterRow(character: character)
                            }
                        }
                    }
                    HStack {
                        if totalPages > 1 {
                            Button(action: {
                                if api.filters.currentPage > 1 {
                                    api.filters.currentPage -= 1
                                }
                            }) {
                                Text("Previous")
                            }
                            pageSlider
                            Button(action: {
                                if Int(api.filters.currentPage) < totalPages {
                                    api.filters.currentPage += 1
                                }
                            }) {
                                Text("Next")
                            }
                        }
                    }.padding()
                } else {
                    ZStack(alignment: .bottom) {
                        VStack {
                            List(api.characters.indices , id: \.self) { index in
                                NavigationLink(destination: DetailView(character: api.characters[index], rootIsActive: $rootIsActive).environmentObject(api)) {
                                    CharacterRow(character: api.characters[index])
                                }
                            }
                            
                            
                            HStack {
                                if Int(maxPages) > 1 {
                                    Button(action: {
                                        if api.filters.currentPage > 1 {
                                            api.filters.currentPage -= 1
                                        }
                                    }) {
                                        Text("Previous")
                                    }
                                    
                                    pageSlider
                                    
                                    Button(action: {
                                        if Int(api.filters.currentPage) < Int(maxPages) {
                                            api.filters.currentPage += 1
                                        }
                                    }) {
                                        Text("Next")
                                    }
                                }
                            }.padding()
                            
                            
                        }
                        Text("Page \(Int(api.filters.currentPage))").padding()
                    }
                }
            }
        }
        // When currentPage, episode, selectedGender, selectedStatus or species changes, call applyFilters().
        .onReceive(api.filters.$currentPage) { _ in
            if !(api.episodeCharacters.isEmpty && !api.characters.isEmpty && !api.filters.episode.isEmpty) {
                api.getCharacters()
            }
        }
        .onChange(of: api.filters.currentPage) { _ in
            applyFilters()
        }
        .onChange(of: api.filters.episode) { _ in
            applyFilters(isInitialLoad: true)
        }
        .onChange(of: api.filters.selectedGender) { _ in
            applyFilters(isInitialLoad: true)
        }
        .onChange(of: api.filters.selectedStatus) { _ in
            applyFilters(isInitialLoad: true)
        }
        .onChange(of: api.filters.species) { _ in
            applyFilters(isInitialLoad: true)
        }
    }
    
    // Update the current page of characters based on the filters currently in use.
    func applyFilters(isInitialLoad: Bool = false) {
        if isInitialLoad {
            api.filters.currentPage = 1
            if !api.filters.episode.isEmpty {
                api.getCharactersFromEpisode()
            } else {
                api.getCharacters()
            }
        } else {
            if !api.filters.episode.isEmpty {
                
                api.updateCurrentPageOfCharacters()
                
            } else {
                api.getCharacters()
            }
        }
    }
}
