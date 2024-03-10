import UIKit
import Alamofire
import AlamofireImage
import Defaults

class SphereInventoryViewController: AlertViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let modelVC = ModelViewController()
        // Assuming you have a way to get the file names for the obj, mtl, and jpg files for the item at the indexPath
        modelVC.objFileName = "yourModelFileName"
        modelVC.mtlFileName = "yourMtlFileName"
        modelVC.textureFileName = "yourTextureFileName"
        //self.navigationController?.pushViewController(modelVC, animated: true)
        goToModel()
    }

    func goToModel() {
        // Get the frame of the existing view controller's view
            let frame = self.view.frame
        
        // User is not signed in
        var rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ModelViewController") as? ModelViewController
        
        // Set the frame of the new view controller's view to match the existing view controller's frame
        rootViewController!.view.frame = frame

        // Assuming you have a reference to your app's UIWindow object
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as? VideoCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        if indexPath.section == 1 {
            let videoURL = URL(string: completedModels[indexPath.row].videoLocation!)
            let label = completedModels[indexPath.row].textPrompt
            print(videoURL!)
            cell.configure(withURL: videoURL!, labelText: label) // Customize the label text as needed
        } else if indexPath.section == 0 {
            let label = "Pending: \(pendingModels[indexPath.row].textPrompt)"
            cell.configureForTextOnly(labelText: label)
        } else {
            // Handle unexpected section or provide a default cell configuration
            // This is a generic fallback. Adjust according to your needs.
            cell.configureForTextOnly(labelText: "Unknown Item")
        }

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
