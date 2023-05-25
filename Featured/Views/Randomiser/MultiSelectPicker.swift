//
//  MultipleSelectionList.swift
//  Featured
//
//  Created by Joost van Grieken on 15/05/2023.
//

import SwiftUI

struct MultiSelectPicker: View {
    
    @State var era: [String] = ["1930", "1940", "1950", "1960", "1970", "1980", "1990", "2000", "2010", "2020"]
    @State var score: [String] = ["1.0", "2.0", "3.0", "4.0", "5.0", "6.0", "7.0", "8.0", "9.0", "10.0"]
    @State var genres: [String] = ["Action", "Comedy", "Drama", "Fantasy", "Horror", "Romance", "Thriller"]
    @State var languages: [String] = ["English", "French", "German", "Japanese", "Korean", "Spanish"]
    @State var providers: [String] = ["Netflix", "Amazon Prime Video", "Hulu", "Disney+", "Apple TV+", "HBO Max"]
    @State var regions: [String] = ["US", "UK", "CA", "AU", "DE", "FR", "JP", "KR", "ES"]
    @State var selections: [String] = []
    
    var body: some View {
        List {
            ForEach(self.era, id: \.self) { item in
                MultipleSelectionRow(title: item, isSelected: self.selections.contains(item)) {
                    if self.selections.contains(item) {
                        self.selections.removeAll(where: { $0 == item })
                    }
                    else {
                        self.selections.append(item)
                    }
                }
            }

            ForEach(self.score, id: \.self) { item in
                MultipleSelectionRow(title: item, isSelected: self.selections.contains(item)) {
                    if self.selections.contains(item) {
                        self.selections.removeAll(where: { $0 == item })
                    }
                    else {
                        self.selections.append(item)
                    }
                }
            }

            ForEach(self.genres, id: \.self) { item in
                MultipleSelectionRow(title: item, isSelected: self.selections.contains(item)) {
                    if self.selections.contains(item) {
                        self.selections.removeAll(where: { $0 == item })
                    }
                    else {
                        self.selections.append(item)
                    }
                }
            }

            ForEach(self.languages, id: \.self) { item in
                MultipleSelectionRow(title: item, isSelected: self.selections.contains(item)) {
                    if self.selections.contains(item) {
                        self.selections.removeAll(where: { $0 == item })
                    }
                    else {
                        self.selections.append(item)
                    }
                }
            }

            ForEach(self.providers, id: \.self) { item in
                MultipleSelectionRow(title: item, isSelected: self.selections.contains(item)) {
                    if self.selections.contains(item) {
                        self.selections.removeAll(where: { $0 == item })
                    }
                    else {
                        self.selections.append(item)
                    }
                }
            }

            ForEach(self.regions, id: \.self) { item in
                MultipleSelectionRow(title: item, isSelected: self.selections.contains(item)) {
                    if self.selections.contains(item) {
                        self.selections.removeAll(where: { $0 == item })
                    }
                    else {
                        self.selections.append(item)
                    }
                }
            }

            ForEach(self.selections, id: \.self) { item in
                MultipleSelectionRow(title: item, isSelected: self.selections.contains(item)) {
                    if self.selections.contains(item) {
                        self.selections.removeAll(where: { $0 == item })
                    }
                    else {
                        self.selections.append(item)
                    }
                }
            }
        }
    }
}

struct MultipleSelectionList_Previews: PreviewProvider {
    static var previews: some View {
        MultiSelectPicker()
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
