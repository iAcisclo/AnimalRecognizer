//
//  VisionManager.swift
//  InsectRecognizer
//
//  Created by Ignacio Acisclo on 21/05/2020.
//  Copyright © 2020 iAcisclo. All rights reserved.
//

import UIKit
import Vision

enum Animal: String {
    case cat, dog
}

class MLManager {
    
    var model = CatDogUpdatable()
    func predict(image: UIImage) -> String? {
        do{
            let imageOptions: [MLFeatureValue.ImageOption: Any] = [.cropAndScale: VNImageCropAndScaleOption.scaleFill.rawValue]
            let featureValue = try MLFeatureValue(cgImage: image.cgImage!, constraint: model.imageConstraint, options: imageOptions)
            return model.predictLabelFor(featureValue)
        }catch(let error){
            return "\(error.localizedDescription)"
        }
    }
    
    private func trainingData(image: UIImage, animalType: Animal ) throws -> MLBatchProvider {
           
        var featureProviders: [MLDictionaryFeatureProvider] = []
        let inputName = "image"
        let outputName = "classLabel"
        let imageOptions: [MLFeatureValue.ImageOption: Any] = [
            .cropAndScale: VNImageCropAndScaleOption.scaleFill.rawValue
        ]
        let inputValue = try MLFeatureValue(cgImage: image.cgImage!, constraint: model.imageConstraint, options: imageOptions)
        let outputValue = MLFeatureValue(string: animalType.rawValue)
        let dataPointFeatures: [String: MLFeatureValue] = [inputName: inputValue, outputName: outputValue]
        
        if let provider = try? MLDictionaryFeatureProvider(dictionary: dataPointFeatures) {
            featureProviders.append(provider)
        }
        return MLArrayBatchProvider(array: featureProviders)
    }
    
    private func updateModel(with trainingData: MLBatchProvider, completionHandler: @escaping (MLUpdateContext) -> Void) {
        do {
            let updateTask = try MLUpdateTask(forModelAt: CatDogUpdatable.urlOfModelInThisBundle, trainingData: trainingData, configuration: nil, completionHandler: completionHandler)
            updateTask.resume()
        } catch (let error){
            print("Could't create an MLUpdateTask. \(error)")
        }
    }

    func saveImage(_ image: UIImage, animalType: Animal, completionHandler: @escaping () -> Void) {
        do {
            let trainingData = try self.trainingData(image: image, animalType: animalType)
            DispatchQueue.global(qos: .userInitiated).async {
                self.updateModel(with: trainingData) { context in
                    print(context)
                    DispatchQueue.main.async { completionHandler() }
                }
            }
        } catch {
          print("Error updating model", error)
        }
    }
}

extension CatDogUpdatable {
    
    var imageConstraint: MLImageConstraint {
        return model.modelDescription.inputDescriptionsByName["image"]!.imageConstraint!
    }
    
    func predictLabelFor(_ value: MLFeatureValue) -> String? {
      guard
        let pixelBuffer = value.imageBufferValue,
          let prediction = try? prediction(image: pixelBuffer).classLabel
        else {
           return nil
      }
      if prediction == "unknown" {
        print("No prediction found")
        return nil
      }
      return prediction
    }
}
