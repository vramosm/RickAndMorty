//
//  Api.swift
//  RickAndMorty
//
//  Created by Victor Ramos on 22/4/24.
//

import Foundation

class Api: ObservableObject {
    @Published var shouldPopToRootView = false
    @Published var characters: [Character] = []
    @Published var totalPages = 0
    @Published var filters = Filters()
    @Published var apiErrorMessage: String? = nil
    @Published var episodeCharacters: [Character] = []
    @Published var currentPageOfCharacters: [Character] = []
    var components = URLComponents(string: "https://rickandmortyapi.com/api/character")!
    
    // Initializing the API and fetch characters when App launches
    init() {
        getCharacters()
    }
    
    // This function is responsible for sending an HTTP request to server with API URL including the page number and any filters applied by user.
    func getPage(page: Int) {
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page))
        ]
        
        if filters.selectedStatus != .all {
            queryItems.append(URLQueryItem(name: "status", value: filters.selectedStatus.rawValue))
        }
        if filters.selectedGender != .all {
            queryItems.append(URLQueryItem(name: "gender", value: filters.selectedGender.rawValue))
        }
        if !filters.species.isEmpty {
            queryItems.append(URLQueryItem(name: "species", value: filters.species))
        }
        
        components.queryItems = queryItems
        
        let request = URLRequest(url: components.url!)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to get data from server with Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(CharacterResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.characters.append(contentsOf: decodedResponse.results)
                        self.totalPages = max(decodedResponse.info.pages, 1)
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            } else {
                print("Data from server was corrupted or nil")
            }
        }.resume()
    }
    
    // Fetch all characters from all pages
    func getAllPages() {
        if filters.episode.isEmpty {
            characters = []
            for page in 1...totalPages {
                getPage(page: page)
            }
        } else {
            self.characters = []
        }
    }
    
    // When called, it sends an HTTP request to the server with API URL including the current page number and any filters applied by user.
    func getCharacters() {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(filters.currentPage)),
        ]
        
        if filters.selectedStatus != .all {
            queryItems.append(URLQueryItem(name: "status", value: filters.selectedStatus.rawValue))
        }
        
        if filters.selectedGender != .all {
            queryItems.append(URLQueryItem(name: "gender", value: filters.selectedGender.rawValue))
        }
        
        if !filters.species.isEmpty {
            queryItems.append(URLQueryItem(name: "species", value: filters.species))
        }
        
        if !filters.episode.isEmpty {
            queryItems.append(URLQueryItem(name: "episode", value: filters.episode))
        }
        
        components.queryItems = queryItems
        let request = URLRequest(url: components.url!)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in Session, \(error)")
                DispatchQueue.main.async {
                    self.characters = []
                    if let decodingError = error as? DecodingError {
                        self.apiErrorMessage = "Error decoding data: \(decodingError.localizedDescription)"
                    } else {
                        self.apiErrorMessage = "No characters found based on your filters."
                    }
                    self.totalPages = 1
                }
                return
            }
            
            guard let data = data else { return }
            do {
                let decodedResponse = try JSONDecoder().decode(CharacterResponse.self, from: data)
                DispatchQueue.main.async {
                    self.characters.removeAll()
                    self.characters.append(contentsOf: decodedResponse.results)
                    self.apiErrorMessage = nil
                    self.apiErrorMessage = decodedResponse.results.isEmpty ? "No characters found." : nil
                    self.totalPages = decodedResponse.info.pages
                }
            } catch {
                
                print("Decoding Error, \(error)")
                DispatchQueue.main.async {
                    self.characters = []
                    self.apiErrorMessage = "No characters found."
                    self.totalPages = 1
                }
            }
            
        }.resume()
    }
    
    // This function is responsible for fetching all character URLs in an episode and then downloading all characters one by one.
    func getCharactersFromEpisode() {
        guard let episodeId = Int(filters.episode), episodeId > 0 else {
            self.apiErrorMessage = "Invalid episode number."
            return
        }
        let url = URL(string: "https://rickandmortyapi.com/api/episode/\(episodeId)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                self.apiErrorMessage = "Network error: \(error.localizedDescription)"
                self.characters = []
            } else if let data = data {
                do {
                    let episodeResponse = try JSONDecoder().decode(Episode.self, from: data)
                    self.downloadCharacters(urls: episodeResponse.characters)
                } catch {
                    print("Decoding error: \(error)")
                    DispatchQueue.main.async {
                        self.characters = []
                        self.apiErrorMessage = "No characters found in this episode."
                        self.totalPages = 1
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.characters = []
                    self.apiErrorMessage = "No characters found in this episode."
                    self.totalPages = 1
                }
            }
        }.resume()
    }
    
    // Takes an array of URLs which are API URLs of different characters and fetches character data one by one for each URL.
    func downloadCharacters(urls: [String]) {
        let characterUrls = urls.compactMap(URL.init)
        var characters: [Character] = []
        let dispatchGroup = DispatchGroup()
        for url in characterUrls {
            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data,
                   let character = try? JSONDecoder().decode(Character.self, from: data) {
                    if (self.filters.selectedStatus == .all || character.status.lowercased() == self.filters.selectedStatus.rawValue) &&
                        (self.filters.selectedGender == .all || character.gender.lowercased() == self.filters.selectedGender.rawValue) &&
                        (self.filters.species.isEmpty || character.species.lowercased().contains(self.filters.species.lowercased())) {
                        characters.append(character)
                    }
                }
                dispatchGroup.leave()
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.episodeCharacters = characters
            self.updateCurrentPageOfCharacters()
            if self.episodeCharacters.isEmpty {
                self.apiErrorMessage = "No characters found in this episode."
            }
        }
    }
    
    // After fetching characters for a single episode, it calculates the startIndex and endIndex based on the current page number and filters out characters for that specific page only.
    func updateCurrentPageOfCharacters() {
        let totalEpisodePages = (episodeCharacters.count + 20 - 1) / 20
        if Int(filters.currentPage) > totalEpisodePages {
            filters.currentPage = 1
        }
        let startIndex = (Int(filters.currentPage) - 1) * 20
        let endIndex = min(startIndex + 20, episodeCharacters.count)
        currentPageOfCharacters = Array(episodeCharacters[startIndex..<endIndex])
    }
}
