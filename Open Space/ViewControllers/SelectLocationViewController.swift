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

class SelectLocationViewController: AlertViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        if collectionView.cellForItem(at: indexPath) != nil {
            //cell.contentView.backgroundColor = .red
        }
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
            //need to travel = yes
            appDelegate.gameState.goingToLocationState = LocationState.allCases[indexPath.row]
//            self.dismiss(animated: true, completion: {

  //          })
            self.performSegue(withIdentifier: "goToGame", sender: self)

            //self.present(NavGameController(), animated: true)
            //self.dismiss(animated: true, completion: nil)
            
            //self.parent?.dismiss(animated: true, completion: nil)
         }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationIdentifier", for: indexPath) as! LocationCollectionViewCell
        cell.backgroundColor = .green
        var cellImage:UIImage?
        if(indexPath.row == 0) {
            cellImage = UIImage(named: "earth.png")
        }
        else if(indexPath.row == 1) {
            cellImage = UIImage(named: "iss.png")
        }
        else if(indexPath.row == 2) {
            cellImage = UIImage(named: "moon.png")
        }
        else if(indexPath.row == 3) {
            cellImage = UIImage(named: "mars.png")
        }
        
        let size = CGSize(width: 100, height: 100)
        let aspectScaledToFitImage = cellImage?.af.imageAspectScaled(toFill: size)
        cell.cellImage.image = aspectScaledToFitImage
        cell.cellLabel.text = self.locations[indexPath.row]
        return cell
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locations = [0: "Earth", 1: "ISS", 2: "Moon", 3: "Mars"]
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
            _ = collectionViewLayout as! UICollectionViewFlowLayout
            let widthPerItem = 200 //collectionView.frame.width / 2 - lay.minimumInteritemSpacing

    return CGSize(width:widthPerItem, height:widthPerItem)
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: false, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        //segue.destination.viewDidDisappear(false)
    }

}
