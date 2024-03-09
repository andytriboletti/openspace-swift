import UIKit
import Alamofire
import AlamofireImage
import Defaults

class SphereInventoryViewController: AlertViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = 200
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    var pendingModels: [OpenspaceAPI.PromptData] = []
    var completedModels: [OpenspaceAPI.PromptData] = []
    
       // Rest of your class code...
       
       func fetchData() {
           let email = Defaults[.email]
           let authToken = Defaults[.authToken]

           OpenspaceAPI.shared.fetchData(email: email, authToken: authToken) { result in
               switch result {
               case .success(let responseData):
                   self.pendingModels = responseData.pending
                   self.completedModels = responseData.completed
                   DispatchQueue.main.async {
                       self.collectionView.reloadData()
                   }
               case .failure(let error):
                   print("Error fetching data: \(error)")
               }
           }
       }

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
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
        
        var iconName: String
        
        if indexPath.section == 0 {
            let promptData = pendingModels[indexPath.row]
            cell.cellLabel?.text = promptData.textPrompt
            iconName = "processing_model_icon.jpg"
        } else {
            let promptData = completedModels[indexPath.row]
            cell.cellLabel?.text = promptData.textPrompt
            iconName = "completed_model_icon.jpg"
        }
        
        // Set the cell's icon image if needed
        // cell.iconImageView?.image = UIImage(named: iconName)
        
        return cell
    }

    func convertToDictionaryWithIntKeys(array: [[String: String]]) -> [Int: [String: String]] {
        var resultDictionary: [Int: [String: String]] = [:]
        for (index, element) in array.enumerated() {
            resultDictionary[index] = element
        }
        return resultDictionary
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 20
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as? HeaderView else {
                fatalError("Failed to dequeue a reusable supplementary view of kind: \(kind) with identifier: HeaderView")
            }

            if indexPath.section == 0 {
                headerView.titleLabel.text = "Pending"
            } else {
                headerView.titleLabel.text = "Completed"
            }
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }
}
