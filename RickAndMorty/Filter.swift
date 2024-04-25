//
//  Filter.swift
//  RickAndMorty
//
//  Created by Victor Ramos on 22/4/24.
//

import Foundation
class Filters : ObservableObject {
    @Published var currentPage: Double = 1
    @Published var selectedGender = Gender.all
    @Published var selectedStatus = Status.all
    @Published var species = ""
    @Published var episode = ""
    
    enum Status: String, CaseIterable {
        case all = "All"
        case alive = "alive"
        case dead = "dead"
        case unknown = "unknown"
    }
    
    enum Gender: String, CaseIterable {
        case all = "All"
        case female = "female"
        case male = "male"
        case unknown = "unknown"
    }
    
    func clearFilters(status: Status = .all, gender: Gender = .all, species: String = "", episode: String = "") {
        self.currentPage = 1
        self.selectedStatus = status
        self.selectedGender = gender
        self.species = species
        self.episode = episode
    }
}
