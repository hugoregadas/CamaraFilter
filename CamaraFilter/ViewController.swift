//
//  ViewController.swift
//  CamaraFilter
//
//  Created by Hugo Regadas on 18/04/2022.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    //MARK: - IBOutlet
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var filterButton: UIButton!
    
    //MARK: - Private var
    let disposeBag = DisposeBag()
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//MARK: - Private methods update UI
private extension ViewController {
    func updateUI(with image: UIImage) {
        self.selectedImageView.image = image
        self.filterButton.isHidden = false
    }
}

//MARK: -Private methods actions
private extension ViewController {
    @IBAction func showPhotoCollectionViewAction(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "PhotosCollectionViewController") as? PhotosCollectionViewController else {
            fatalError("Error View controller")
        }
        
        vc.selectedPhoto.subscribe { [weak self] image in
            DispatchQueue.main.async {
                self?.updateUI(with: image)
            }
        } onError: { error in
            print(error.localizedDescription)
        } onCompleted: {
            print("Completed")
        } onDisposed: {
            print("disposed")
        }.disposed(by: disposeBag)
        
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func applyFilterAction(_ sender: UIButton) {
        guard let sourceImage = self.selectedImageView.image else {
            return
        }
        
        FilterService().applyFilter(to: sourceImage).subscribe { [weak self ]image in
            DispatchQueue.main.async {
                self?.updateUI(with: image)
            }
        } onError: { error in
            print(error.localizedDescription)
        } onCompleted: {
            print("Completed filter")
        } onDisposed: {
            print("disposed filter")
        }.disposed(by: disposeBag)
    }
}

