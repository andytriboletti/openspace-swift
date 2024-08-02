import UIKit
import Defaults

class SphereInventoryViewController: AlertViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.section == 0) {
            let meshZipURL = completedModels[indexPath.row].meshLocation
            let modelPrompt = completedModels[indexPath.row].textPrompt
            let modelId = completedModels[indexPath.row].meshId
            //print("mesh zip url")
            //print(meshZipURL as Any)
            //print("end mesh zip url")
            Defaults[.selectedMeshLocation] = meshZipURL!
            Defaults[.selectedMeshPrompt] = modelPrompt
            Defaults[.selectedMeshId] = modelId
            goToModel()
        }
        else if(indexPath.section == 1) {
            let meshZipURL = pendingModels[indexPath.row].meshLocation
            let modelPrompt = pendingModels[indexPath.row].textPrompt
            let modelId = pendingModels[indexPath.row].meshId

            //print("pending mesh zip url")
            //print(meshZipURL as Any)
            //print("pending end mesh zip url")
            Defaults[.selectedMeshLocation] = "" //meshZipURL!
            Defaults[.selectedMeshPrompt] = modelPrompt
            Defaults[.selectedMeshId] = modelId
            goToModel()
        }

    }

//    func goToModel() {
//        // Get the frame of the existing view controller's view
//        let frame = self.view.frame
//
//        // User is not signed in
//        let rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ModelViewController") as? ModelViewController
//
//        // Set the frame of the new view controller's view to match the existing view controller's frame
//        rootViewController!.view.frame = frame
//
//        // Assuming you have a reference to your app's UIWindow object
//        guard let window = UIApplication.shared.windows.first else {
//            return
//        }
//        window.rootViewController = rootViewController
//        window.makeKeyAndVisible()
//    }

//    func goToModel() {
//        // Get the frame of the existing view controller's view
//        let frame = self.view.frame
//
//        // User is not signed in
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let rootViewController = storyboard.instantiateViewController(withIdentifier: "ModelViewController") as? ModelViewController else {
//            //print("Error: Could not find view controller with identifier 'ModelViewController'")
//            return
//        }
//
//        // Set the frame of the new view controller's view to match the existing view controller's frame
//        rootViewController.view.frame = frame
//
//        // Assuming you have a reference to your app's UIWindow object
//        guard let window = UIApplication.shared.windows.first else {
//            //print("Error: Could not find the application's window")
//            return
//        }
//        window.rootViewController = rootViewController
//        window.makeKeyAndVisible()
//    }


    func goToModel() {
        // User is not signed in
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let rootViewController = storyboard.instantiateViewController(withIdentifier: "ModelViewController") as? ModelViewController else {
            //print("Error: Could not find view controller with identifier 'ModelViewController'")
            return
        }

        // Set the modal presentation style to full screen
        rootViewController.modalPresentationStyle = .fullScreen

        // Present the new view controller modally
        self.present(rootViewController, animated: true, completion: nil)
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
        let yourSphereId = Defaults[.selectedSphereId]

        OpenspaceAPI.shared.fetchData(email: email, authToken: authToken, sphereId: yourSphereId) { result in
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
        if section == 1 {
            return pendingModels.count
        } else {
            return completedModels.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as? VideoCollectionViewCell else {
            fatalError("Unexpected cell type")
        }

        if indexPath.section == 0 {
            let videoURL = URL(string: completedModels[indexPath.row].videoLocation!)
            let label = completedModels[indexPath.row].textPrompt
            let acceptableName = completedModels[indexPath.row].acceptableName
            if(acceptableName == 0) {
                let acceptableName = "(Moderated) " + completedModels[indexPath.row].textPrompt
            }

            //print(videoURL!)


            // Use the FileDownloader to cache the video file
            FileDownloader.shared.downloadFile(from: videoURL!) { cachedURL in
                DispatchQueue.main.async {
                    if let cachedURL = cachedURL {
                        cell.configure(withURL: cachedURL, labelText: label)
                    } else {
                        cell.configure(withURL: videoURL!, labelText: label) // Fallback to original URL if caching fails
                    }
                }
            }
        } else if indexPath.section == 1 {
            var label = "Pending"
            let acceptableName = completedModels[indexPath.row].acceptableName

            if(pendingModels[indexPath.row].error == 1) {
                label = "Error: \(pendingModels[indexPath.row].textPrompt)"

                if(acceptableName == 0) {
                    let acceptableName = "(Moderated) Error: " + completedModels[indexPath.row].textPrompt
                }

            }
            else {
                label = "Pending: \(pendingModels[indexPath.row].textPrompt)"
                if(acceptableName == 0) {
                    let acceptableName = "(Moderated) Pending: " + completedModels[indexPath.row].textPrompt
                }
            }


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
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: "VideoCollectionViewCell")

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

            if indexPath.section == 1 {
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
