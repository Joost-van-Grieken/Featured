//
//  ActivityIndicatView.swift
//  Featured2
//
//  Created by Joost van Grieken on 06/04/2023.
//

// MARK: Hantert de laad icoon

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
}
