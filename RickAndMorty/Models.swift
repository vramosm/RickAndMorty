//
//  Models.swift
//  RickAndMorty
//
//  Created by Victor Ramos on 22/4/24.
//

import Foundation

struct Character: Identifiable, Decodable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
    let origin: [String : String]
    let location: [String: String]
    let image: String
    let episode: [String]
    let url: String
    let created: String
}

struct Info: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

struct CharacterResponse: Decodable {
    let info: Info
    let results: [Character]
    
}

struct Episode: Decodable {
    let characters: [String]
}
