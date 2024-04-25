//
//  Array+Identifiable.swift
//  RickAndMorty
//
//  Created by Victor Ramos on 22/4/24.
//

import Foundation
extension Array where Element: Identifiable {
    func isLast(_ item: Element) -> Bool {
        guard let lastItem = self.last else {
            return false
        }
        return lastItem.id == item.id
    }
}
