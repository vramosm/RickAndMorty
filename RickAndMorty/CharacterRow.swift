//
//  CharacterRow.swift
//  RickAndMorty
//
//  Created by Victor Ramos on 22/4/24.
//

import SwiftUI
import Kingfisher

struct CharacterRow: View {
    let character: Character
    
    var body: some View {
        HStack {
            KFImage(URL(string: character.image)) 
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .cornerRadius(40)
            
            Text(character.name)
                .font(.title)
            
            Spacer()
        }
    }
}
