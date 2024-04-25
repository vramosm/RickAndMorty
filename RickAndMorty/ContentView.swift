//
//  ContentView.swift
//  RickAndMorty
//
//  Created by Victor Ramos on 22/4/24.
//

import SwiftUI
import Kingfisher

struct ContentView: View {
    @EnvironmentObject var api: Api
    @State private var rootIsActive = false
    
    var body: some View {
        NavigationView {  // Main Navigation
            ZStack(alignment: .top) {
                VStack { // VStack to align views vertically
                    filterView  // UI for filters
                    CharacterListView(rootIsActive: $rootIsActive)  // List of Characters
                    Spacer()
                }
            }
            .onChange(of: api.shouldPopToRootView) { value in
                api.shouldPopToRootView = false
            }
        }
    }
    
    // Filter UI view
    private var filterView: some View {
        VStack {
            // Picker for Status
            Picker("Status", selection: $api.filters.selectedStatus) {
                ForEach(Filters.Status.allCases, id: \.self) { status in
                    Text(status.rawValue.capitalized)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Picker for Gender
            Picker("Gender", selection: $api.filters.selectedGender) {
                ForEach(Filters.Gender.allCases, id: \.self) { gender in
                    Text(gender.rawValue.capitalized)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // TextField input for Episode with a clear button
            TextField("Episode", text: $api.filters.episode)
                .padding()
                .overlay(Button(action: { api.filters.episode = "" }) {
                    Image(systemName: "xmark.circle").padding().foregroundColor(.gray)
                }.padding(.trailing), alignment: .trailing)
            
            // TextField input for Species with a clear button
            TextField("Species", text: $api.filters.species)
                .padding()
                .overlay(Button(action: { api.filters.species = "" }) {
                    Image(systemName: "xmark.circle").padding().foregroundColor(.gray)
                }.padding(.trailing), alignment: .trailing)  
        }
    }
}

// PreviewProvider for SwiftUI Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Api())
    }
}
