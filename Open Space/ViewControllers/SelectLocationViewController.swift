//
//  SelectLocationViewController.swift
//  Open Space
//
//  Created by Andy Triboletti on 2/21/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class SelectLocationViewController: AlertViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationIdentifier", for: indexPath) as! LocationCollectionViewCell
        cell.backgroundColor = .green
        let cellImage = UIImage(named: "rocket_1024.png")
        let size = CGSize(width: 230, height: 230)
        let aspectScaledToFitImage = cellImage?.af_imageAspectScaled(toFill: size)
        cell.cellImage.image = aspectScaledToFitImage
        return cell
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewFlowLayout.itemSize = CGSize(width: 128, height: 128)
        
    }
    

}
