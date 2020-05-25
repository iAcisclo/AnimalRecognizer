//
//  FirstViewController.swift
//  AnimalRecognizer
//
//  Created by Ignacio Acisclo on 22/05/2020.
//  Copyright © 2020 iAcisclo. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    let imageProvider = ImageProvider()
    let mlManager = MLManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        next(nil)
    }

    @IBAction func next(_ sender: Any?) {
        self.imageView.image = nil
        self.textLabel.text = ""
        imageProvider.animalImage(type: .random, onCompletion: { image in
            self.imageView.image = image
            self.textLabel.text = self.mlManager.predict(image: image)
        })
    }
}
