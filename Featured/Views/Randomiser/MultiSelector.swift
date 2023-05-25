//
//  MultiSelector.swift
//  Featured
//
//  Created by Joost van Grieken on 17/05/2023.
//

import SwiftUI

struct MultiSelector<LabelView: View, Selectable: Identifiable & Hashable>: View {
    let label: LabelView
    let options: [Selectable]
    let optionToString: (Selectable) -> String
    var selected: Binding<Set<Selectable>>

    private let maxVisibleOptions = 3 // Maximum number of visible options

    private var formattedSelectedListString: String {
        let selectedOptions = selected.wrappedValue
        let selectedCount = selectedOptions.count
        var formattedString = ""

        if selectedCount > maxVisibleOptions {
            let visibleOptions = selectedOptions.prefix(maxVisibleOptions).map { optionToString($0) }
            formattedString = ListFormatter.localizedString(byJoining: visibleOptions)
            formattedString += " ...+"
        } else {
            formattedString = ListFormatter.localizedString(byJoining: selectedOptions.map { optionToString($0) })
        }

        return formattedString
    }

    var body: some View {
        NavigationLink(destination: multiSelectionView()) {
            HStack {
                label
                Spacer()
                Text(formattedSelectedListString)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private func multiSelectionView() -> some View {
        MultiSelectionView(
            options: options,
            optionToString: optionToString,
            selected: selected
        )
    }
}

struct MultiSelector_Previews: PreviewProvider {
    struct IdentifiableString: Identifiable, Hashable {
        let string: String
        var id: String { string }
    }

    @State static var selected: Set<IdentifiableString> = Set(["A", "C"].map { IdentifiableString(string: $0) })

    static var previews: some View {
        NavigationView {
            Form {
                MultiSelector<Text, IdentifiableString>(
                    label: Text("Multiselect"),
                    options: ["A", "B", "C", "D"].map { IdentifiableString(string: $0) },
                    optionToString: { $0.string },
                    selected: $selected
                )
            }.navigationTitle("Title")
        }
    }
}


struct Task {
    var name: String
    var servingFilters: Set<Filter>
}

struct Filter: Hashable, Identifiable {
    var id: String { name }
    var name: String
}

struct FilterGenres: Hashable, Identifiable {
    var id: String { name }
    var name: String
    let number: Int
    
    init(name: String, number: Int) {
            self.name = name
            self.number = number
        }
}
