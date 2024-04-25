//
//  DetailView.swift
//  RickAndMorty
//
//  Created by Victor Ramos on 22/4/24.
//

import SwiftUI
import Kingfisher

struct DetailView: View {
    let character: Character
    @EnvironmentObject var api: Api
    @Binding var rootIsActive: Bool
    
    @State private var navigate = false
    
    var body: some View {
        ScrollView {
            VStack {
                // Kingfisher view for loading images from a URL
                KFImage(URL(string: character.image))
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(20)
                    .padding()
                // Title for character
                Text(character.name)
                    .font(.largeTitle)
                    .fontWeight(.black)
                // Filter buttons
                filterButton("Status: \(character.status)") {
                    if let status = Filters.Status(rawValue: character.status) {
                        api.filters.selectedStatus = status
                        api.getAllPages()
                        api.shouldPopToRootView.toggle()
                    }
                }
                filterButton("Species: \(character.species)") {
                    api.filters.species = character.species
                    api.getAllPages()
                    api.shouldPopToRootView.toggle()
                }
                filterButton("Gender: \(character.gender)") {
                    if let gender = Filters.Gender(rawValue: character.gender) {
                        api.filters.selectedGender = gender
                        api.getAllPages()
                        api.shouldPopToRootView.toggle()    
                    }
                }
                // Display other details
                Text("Origin: \(character.origin["name"] ?? "N/A")")
                    .font(.headline)
                
                Text("Location: \(character.location["name"] ?? "N/A")")
                    .font(.headline)
                // Display episodes
                let firstEpisode = URL(string: character.episode.first ?? "")?.lastPathComponent ?? "N/A"
                let lastEpisode = URL(string: character.episode.last ?? "")?.lastPathComponent ?? "N/A"
                
                Text("First Episode: \(firstEpisode)")
                    .font(.headline)
                
                Text("Last Episode: \(lastEpisode)")
                    .font(.headline)
                Spacer()
            }
            .padding(.top, UIScreen.main.bounds.height / 2 - 300)
            
        }.onAppear(perform: {
            api.getCharacters()
        })
        .edgesIgnoringSafeArea(.top)
    }
    
    // This button will be used to apply the associated filter to the data when clicked.
    func filterButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            if title.contains("Status") {
                if let status = Filters.Status(rawValue: character.status.lowercased()) {
                    api.filters.clearFilters(status: status)
                } else {
                    print("Unexpected status: \(character.status)")
                }
            }
            else if title.contains("Species") {
                api.filters.clearFilters(species: character.species)
            }
            else if title.contains("Gender") {
                if let gender = Filters.Gender(rawValue: character.gender.lowercased()) {
                    api.filters.clearFilters(gender: gender)
                } else {
                    print("Unexpected gender: \(character.gender)")
                }
            }
            action()
            api.getAllPages()
            DispatchQueue.main.async {
                rootIsActive = false
            }
        }) {
            HStack {
                Text(title)
                Image(systemName: "arrow.right.arrow.left")
            }
            .padding([.leading, .trailing])
        }
    }
}

struct DetailViewPreviews: PreviewProvider {
    @State static var dummyIsActive = false
    
    static var previews: some View {
        DetailView(
            character: Character(
                id: 1, name: "Test",
                status: "Alive",
                species: "Human",
                gender: "Male",
                origin: ["name": "Earth"],
                location: ["name": "Earth"],
                image: "Test URL",
                episode: ["1"],
                url: "url",
                created: "April, 1, 2022"
            ),
            rootIsActive: $dummyIsActive
        )
        .environmentObject(Api())
    }
}
