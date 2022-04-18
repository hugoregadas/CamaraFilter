//
//  FilterService.swift
//  CamaraFilter
//
//  Created by Hugo Regadas on 18/04/2022.
//

import Foundation
import UIKit
import CoreImage
import RxSwift

class FilterService {
    //MARK: - Private var
    private var context: CIContext
    
    //MARK: - Init
    init(){
        self.context = CIContext()
    }
    
    //MARK: - Publick methods
    func applyFilter(to inputImage: UIImage) -> Observable<UIImage> {
        return Observable<UIImage>.create { observer in
            self.applyFilter(to: inputImage) { image in
                observer.onNext(image)
            }
            
            return Disposables.create()
        }
    }
    
    //MARK: - Private methods
    private func applyFilter(to inputImage: UIImage, completion: @escaping((UIImage) -> ())) {
        let filter = CIFilter(name: "CICMYKHalftone")!
        filter.setValue(3.0, forKey: kCIInputWidthKey)
        
        if let sourceImage = CIImage(image: inputImage) {
            filter.setValue(sourceImage, forKey: kCIInputImageKey)
            
            if let cgimg = self.context.createCGImage(filter.outputImage!, from: filter.outputImage!.extent) {
                let processedImage = UIImage(cgImage: cgimg, scale: inputImage.scale, orientation: inputImage.imageOrientation)
                
                completion(processedImage)
            }
        }
    }
}
