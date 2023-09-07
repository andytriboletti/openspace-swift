//
//  YourSphereViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/6/23.
//  Copyright © 2023 GreenRobot LLC. All rights reserved.
//

import UIKit

class YourSphereViewController: UIViewController {
    @IBOutlet var inputText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func createNewItem() {
        print("create new item")
        print(inputText.text)
        

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */




}
