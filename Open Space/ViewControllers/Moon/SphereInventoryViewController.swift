//
//  SphereInventoryViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/31/23.
//  Copyright © 2023 GreenRobot LLC. All rights reserved.
//

//this class uses mock data right now, it should use the pendingModels and completedModels data once fetchData completes
//instead. The pendingModels should use processing_model_icon.jpg as the icon. IT should have 2 sections, with headers Pending
//and Completed.

import UIKit
import Alamofire
import AlamofireImage
import Defaults

class SphereInventoryViewController: AlertViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var locations: Dictionary<Int, String> = [:]
    var pendingModels: Dictionary<Int, String> = [:]
    var completedModels: Dictionary<Int, String> = [:]
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = 200
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func fetchData() {
        let email = Defaults[.email]
        let authToken = Defaults[.authToken]

        OpenspaceAPI.shared.fetchData(email: email, authToken: authToken) { [weak self] pendingModels, completedModels in
            self?.pendingModels = pendingModels
            self?.completedModels = completedModels
            DispatchQueue.main.async {
                // Perform UICollectionView layout operations here
                self?.collectionView.reloadData() // For example, reloadData() is called on the main thread
            }

        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Two sections for pending and completed models
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return pendingModels.count
        } else {
            return completedModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "modelIdentifier", for: indexPath) as? ModelCollectionViewCell else {
            return UICollectionViewCell()
        }

        var modelDictionary: Dictionary<Int, String> = [:]
        var iconName: String = ""
        
        if indexPath.section == 0 {
            modelDictionary = pendingModels
            iconName = "processing_model_icon.jpg"
        } else {
            modelDictionary = completedModels
            iconName = "completed_model_icon.jpg" // Assuming this is the correct icon for completed models
        }
        
        // Set icon
        cell.cellImage.image = UIImage(named: iconName)
        
        // Set model name
        cell.cellLabel?.text = modelDictionary[indexPath.row]
        
        return cell
    }
    
    // Other methods...
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData()
        self.locations = [0: "Earth", 1: "ISS", 2: "Moon", 3: "Mars"]
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 20
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        // Register header views
        //collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")

    }
    
//    func collectionView(_ collectionView: UICollectionView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return "Pending"
//        } else {
//            return "Completed"
//        }
//    }
//    
//
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50) // Adjust height as needed
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as? HeaderView else {
                fatalError("Failed to dequeue a reusable supplementary view of kind: \(kind) with identifier: HeaderView")
            }

            if(indexPath.section == 0) {
                headerView.titleLabel.text = "Pending"
            }
            if(indexPath.section == 1) {
                headerView.titleLabel.text = "Completed"
            }
            // Configure and return the header view
            return headerView
        } else {
            // Handle other kinds of supplementary views
            return UICollectionReusableView()
        }
    }


    
    // Other methods...
}

