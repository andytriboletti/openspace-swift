//
//  WhereOnEarthSelectCollectionViewController.swift
//  Open Space
//
//  Created by Andy Triboletti on 3/20/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

import UIKit
import Alamofire
import AlamofireImage

class WhereOnEarthSelectCollectionViewController: AlertViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var locations: Dictionary<Int, String> = [:]
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.locations.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }


    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if (collectionView.cellForItem(at: indexPath) as? LocationCollectionViewCell) != nil {
            // cell.backgroundColor = .green
            
         }
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        //if let cell = collectionView.cellForItem(at: indexPath) {
            //cell.contentView.backgroundColor = .red
        //}
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if collectionView.cellForItem(at: indexPath) != nil {
            //cell.contentView.backgroundColor = nil
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected")
        print(indexPath.row)
        print(indexPath.section)
        if (collectionView.cellForItem(at: indexPath) as? LocationCollectionViewCell) != nil {
            //cell.backgroundColor = .red
            //appDelegate.gameState.locationState = LocationState.allCases[indexPath.row]
//            self.dismiss(animated: true, completion: {
            appDelegate.gameState.earthLocationState = EarthLocationState.allCases[indexPath.row]

  //          })
            self.performSegue(withIdentifier: "exploreEarth", sender: self)

            //self.present(NavGameController(), animated: true)
            //self.dismiss(animated: true, completion: nil)
            
            //self.parent?.dismiss(animated: true, completion: nil)
         }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationIdentifier", for: indexPath) as! LocationCollectionViewCell
        cell.backgroundColor = .green
        //let cellImage = UIImage(named: "rocket_1024.png")
        let cellImage = UIImage(named: "space_icon_1024.jpg")
        let size = CGSize(width: 100, height: 100)
        let aspectScaledToFitImage = cellImage?.af.imageAspectScaled(toFill: size)
        cell.cellImage.image = aspectScaledToFitImage
        cell.cellLabel.text = self.locations[indexPath.row]
        return cell
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.locations = [0: "Great Wall of China", 1: "Petra", 2: "Christ the Redeemer", 3: "Machu Picchu", 4: "Chichen Itza", 5: "Colosseum", 6: "Taj Mahal", 7: "Great Pyramid of Giza"]
        
        self.locations = [0: "Great Wall of China", 1: "Taj Mahal", 2: "Petra", 3: "Machu Picchu", 4: "Chichen Itza", 5: "Colosseum", 6: "Christ the Redeemer", 7: "Great Pyramid of Giza"]
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //.horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 20
        collectionView.setCollectionViewLayout(layout, animated: true)
            
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)//here your custom value for spacing
        }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                let lay = collectionViewLayout as! UICollectionViewFlowLayout
                let widthPerItem = collectionView.frame.width / 2 - lay.minimumInteritemSpacing

    return CGSize(width:widthPerItem, height:widthPerItem)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        //segue.destination.viewDidDisappear(false)
    }

    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
