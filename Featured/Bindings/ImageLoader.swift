//
//  ImageLoader.swift
//  Featured2
//
//  Created by Joost van Grieken on 06/04/2023.
//

// MARK: Hanteert alle afbeeldingn.

import SwiftUI
import UIKit

private let _imageCache = NSCache<AnyObject, AnyObject>()

class ImageLoader: ObservableObject {
    
    @Published var image: UIImage?
    @Published var isLoading = false
    
    var imageCache = _imageCache

    func loadImage(with url: URL?) {
        guard let url = url else {
            return
        }
        
        let urlString = url.absoluteString
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else {
                    return
                }
                DispatchQueue.main.async {
                    self.imageCache.setObject(image, forKey: urlString as AnyObject)
                    self.image = image
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
