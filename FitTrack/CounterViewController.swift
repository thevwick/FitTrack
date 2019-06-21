//
//  CounterViewController.swift
//  FitTrack
//  Reference: http://www.thomashanning.com/uitableview-tutorial-for-beginners/#Creating_an_UITableView
//  Created by Ash  on 15/6/19.
//  Copyright © 2019 Thev. All rights reserved.
//

import UIKit
import Firebase

class CounterViewController: UIViewController ,UITableViewDataSource{

    static var currentCal = 0               //Variable to calculate sum of calories
    var receivedFoodObjects = [Food]()      //Array to hold food Objects sent from food Search
    var recentlyAdded = [recentFoodItem]()
    var  userId = ""
    
    
    @IBOutlet weak var recents: UITableView!
    @IBOutlet weak var counterLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set border and border color around calorie counter display
        counterLabel.layer.borderWidth = 2.0
        counterLabel.layer.cornerRadius = 8
        counterLabel.layer.borderColor = UIColor.gray.cgColor
        
       
        
        //Get user id and email of current user
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        self.userId = userUid
        //Reference to database
        let db = Firestore.firestore()
        
        //Get data from firestore and populate recently added food items to calorie counter by current user
        db.collection("users").document(self.userId).setData(["email":userEmail])
        db.collection("users").document(self.userId).collection("recentFood").getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    var foodItem = recentFoodItem(name:"", calories: -1)
                    foodItem.name = document.documentID
                    foodItem.calories = document.data()["calories"] as! Int
                    self.recentlyAdded.append(foodItem)
                    //Limit the number of items shown to 5
                    if self.recentlyAdded.count > 5{
                    db.collection("users").document(self.userId).collection("recentFood").document(self.recentlyAdded[0].name).delete()
                        self.recentlyAdded.remove(at:0)
                    }
                }
                DispatchQueue.main.async {
                    self.recents.reloadData()
                }
            }
            
        }
        
       //When a Food Object is received from food search process its information and add its calories to counter
        if !receivedFoodObjects.isEmpty {
            calorieSum(received: receivedFoodObjects[0].calories)
            let calories = receivedFoodObjects[0].calories
            let name = receivedFoodObjects[0].searched
            let recentItem = recentFoodItem(name: name,calories: calories)
            
            db.collection("users").document(self.userId).collection("recentFood").document(recentItem.name).setData(["calories":recentItem.calories]) //Save the item to firestore

        }
        counterLabel.text = String(CounterViewController.currentCal)
        recents.dataSource = self
      
        

    }
    //Update calorie counter whenever view appears
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        self.counterLabel.setNeedsDisplay()
    }


   //Functionality for reset button - Reset button sets calorie counter to 0
    @IBAction func resetButton(_ sender: Any) {
        
        let resetAlert = UIAlertController(title: "Reset", message: "Calorie count will be set to 0", preferredStyle: UIAlertController.Style.alert)
        
        resetAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            CounterViewController.currentCal = 0
            self.counterLabel.text = String(CounterViewController.currentCal)
           
        }))
        
        resetAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(resetAlert, animated: true, completion: nil)
        
    }
    //Function to add calories from food search to current Cal variable
    func calorieSum(received:Int) {
        CounterViewController.currentCal += received
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentlyAdded.count
    }
    
    //Shows recently added table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "recentlyAddedCell")!
         cell.selectionStyle = .none
         cell.textLabel?.text = recentlyAdded.reversed()[indexPath.row].name
         cell.detailTextLabel?.text = String(recentlyAdded.reversed()[indexPath.row].calories) + " kCal"
         return cell
    }

    struct recentFoodItem{
        var name:String
        var calories:Int
    }
  
}


