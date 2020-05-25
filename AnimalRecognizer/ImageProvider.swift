//
//  ImageProvider.swift
//  AnimalRecognizer
//
//  Created by Ignacio Acisclo on 22/05/2020.
//  Copyright © 2020 iAcisclo. All rights reserved.
//

import UIKit
import Combine

class ImageProvider {
    
    
    enum AnimalImage {
        case cat,dog,random
    }
    
    func animalImage(type: AnimalImage, onCompletion completion: @escaping (UIImage)-> ()) {
        switch type {
        case .cat:
            catImage(onCompletion: completion)
        case .dog:
            dogImage(onCompletion: completion)
        case .random:   
            if Int.random(in: 0..<10) > 5 {
                catImage(onCompletion: completion)
            } else {
                dogImage(onCompletion: completion)
            }
        }
    }
    
    func downloadImage(url: String, onCompletion completion: @escaping (UIImage)-> ()) {
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    func catImage(onCompletion completion: @escaping (UIImage)-> ()) {
        let catURL = "https://placekitten.com/200/\(Int.random(in: 300 ..< 400))"
        downloadImage(url: catURL, onCompletion: completion)
    }
    
    func dogImage(onCompletion completion: @escaping (UIImage)-> ()) {
        URLSession.shared.dataTask(with: URL(string: "https://dog.ceo/api/breeds/image/random")!) { (data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()
            if let result = try? decoder.decode(Dictionary<String, String>.self, from: data), let url = result["message"] {
                self.downloadImage(url: url, onCompletion: completion)
            }
        }.resume()
    }
}
