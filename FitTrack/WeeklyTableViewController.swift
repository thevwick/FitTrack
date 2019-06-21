//
//  WeeklyTableViewController.swift
//  FitTrack
//  Reference: https://learnappmaking.com/uialertcontroller-alerts-swift-how-to/
//  Created by Ash  on 17/6/19.
//  Copyright © 2019 Thev. All rights reserved.
//

import UIKit
import Firebase

class WeeklyTableViewController: UITableViewController {
    var weekName = ""
    var weeks = [String]()
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Get current users User ID and email from firebase
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        self.hideKeyboardWhenTappedAround()
        self.userId = userUid
        
        //Get weekly workout data for current user form firestore
        let db = Firestore.firestore()
        db.collection("users").document(self.userId).setData(["email":userEmail])
        db.collection("users").document(self.userId).collection("weeks").getDocuments{ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.weeks.append(document.documentID)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
           
        }
        

        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return weeks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weekCell", for: indexPath);
        cell.textLabel?.text = weeks[indexPath.row]

        return cell;
    }
    

    //Send week name to next viewcontroller to load data from firestore
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDaily" {
            
            let indexPath = tableView.indexPathForSelectedRow
            let currentCell = tableView.cellForRow(at: indexPath!) as UITableViewCell?;
            weekName = (currentCell?.textLabel!.text!)!
            let weekNameSend = self.weekName
            let destinationVC = segue.destination as! DailyTableViewController
            destinationVC.receivedWeekName = weekNameSend
        }
    }
    
    //Deletes a cell when swiped
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        let db = Firestore.firestore()
        if editingStyle == .delete {
            
            // remove the item from the data model
            db.collection("users").document(self.userId).collection("weeks").document(weeks[row]).delete()
            weeks.remove(at:row)
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }

    @IBAction func addWeek(_ sender: Any) {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Week", message: "Enter Week Name:", preferredStyle: .alert)
        
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textFieldName) in
            textFieldName.placeholder = "Week Name"
        }
        
  
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            print("Cancelled")
        }))
        
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak alert] (_) in
            let textFieldName = alert?.textFields![0]
            let db = Firestore.firestore()
            
            if textFieldName!.text != "" {
                
                db.collection("users").document(self.userId).collection("weeks").document(textFieldName!.text!).setData(["exists" : true])
                        self.weeks.append(textFieldName!.text!)
                
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
            
        
            
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)

        
    }
    

}
