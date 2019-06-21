//
//  ExercisesTableViewController.swift
//  FitTrack
//
//  Created by Ash  on 17/6/19.
//  Copyright © 2019 Thev. All rights reserved.
//
import Firebase
import UIKit

class ExercisesTableViewController: UITableViewController {
    
    var receivedDay = ""
    var receivedWeek = ""
    var exerciseNames = [String]()
    var weightsList = [Int]()
    var repsList = [Int]()
    var userId = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.rowHeight = 150;
        self.navigationItem.title = receivedDay
        self.hideKeyboardWhenTappedAround()
        
        //Get userID of current user from Firestore. Gets exercise info from a specific day
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        self.userId = userUid
        let db = Firestore.firestore()
       db.collection("users").document(self.userId).collection("weeks").document(receivedWeek).collection(receivedDay).getDocuments{ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.exerciseNames.append(document.documentID)
                    self.weightsList.append(document.data()["weight"] as! Int)
                    self.repsList.append(document.data()["reps"] as! Int)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exerciseNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell") as! ExercisesTableViewCell
        
        cell.nameLabel.text = exerciseNames[indexPath.row]
        cell.weightLabel.text = String(weightsList[indexPath.row])
        cell.repsLabel.text = String(repsList[indexPath.row])
        
        return cell
        
    }
    
    //Allows the user to change number of reps and weight when a cell is clicked
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!) as! ExercisesTableViewCell;
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Change Weight/Reps", message: "Enter values to change:", preferredStyle: .alert)
        
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textFieldWeight) in
            textFieldWeight.placeholder = "Weight"
        }
        
        alert.addTextField { (textFieldReps) in
            textFieldReps.placeholder = "reps"
            
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            print("Cancelled")
        }))
        
        alert.addAction(UIAlertAction(title: "Assign", style: .default, handler: { [weak alert] (_) in
            let textFieldWeight = alert?.textFields![0]
            let textFieldReps = alert?.textFields![1]
            let db = Firestore.firestore()
            
            //Updates database when weight is changed
            if textFieldWeight!.text != "" { db.collection("users").document(self.userId).collection("weeks").document(self.receivedWeek).collection(self.receivedDay).document(currentCell.nameLabel.text!).updateData(["weight": Int(textFieldWeight!.text!)!])
                self.weightsList[(indexPath?.row)!] = Int(textFieldWeight!.text!)!

            }
            
            //Updates database when reps are changed
            if textFieldReps!.text != "" { db.collection("users").document(self.userId).collection("weeks").document(self.receivedWeek).collection(self.receivedDay).document(currentCell.nameLabel.text!).updateData(["reps": Int(textFieldReps!.text!)!])
                 self.repsList[(indexPath?.row)!] = Int(textFieldReps!.text!)!
                
            }
            
           
            self.tableView.reloadData()
    

        }))
  
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)

    }
    
    
    //Delete cell when swiped
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        let db = Firestore.firestore()
        if editingStyle == .delete {
            
            // remove the item from the data model
        db.collection("users").document(self.userId).collection("weeks").document(self.receivedWeek).collection(self.receivedDay).document(exerciseNames[row]).delete()
            exerciseNames.remove(at:row)
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    //Functionality for add exercise button
    @IBAction func addExercise(_ sender: Any) {
        let db = Firestore.firestore()
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Exercise", message: "Enter exercise info:", preferredStyle: .alert)
        
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textFieldName) in
            textFieldName.placeholder = "Exercise Name"
        }
        
        alert.addTextField { (textFieldWeight) in
            textFieldWeight.placeholder = "Weight"
        }
        
        alert.addTextField { (textFieldReps) in
            textFieldReps.placeholder = "Reps"
            
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            print("Cancelled")
        }))
        
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak alert] (_) in
            let textFieldName = alert?.textFields![0]
            let textFieldWeight = alert?.textFields![1]
            let textFieldReps = alert?.textFields![2]

            
            if textFieldName!.text != ""{
                if textFieldWeight!.text != "" {
                    if textFieldReps!.text != "" {
                        db.collection("users").document(self.userId).collection("weeks").document(self.receivedWeek).collection(self.receivedDay).document(textFieldName!.text!).setData(["weight":Int(textFieldWeight!.text!)!,"reps":Int(textFieldReps!.text!)!])
                        
                        self.exerciseNames.append(textFieldName!.text!)
                        self.weightsList.append(Int(textFieldWeight!.text!)!)
                        self.repsList.append(Int(textFieldReps!.text!)!)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    else { self.errorAlert() }
                }
                else { self.errorAlert() }
            }
            else { self.errorAlert() }
         
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)

    }
    
    //Alert to display when wrongful information is added in the edit or add exericse segments
    func errorAlert(){
        let alert = UIAlertController(title: "Error", message: "Add all fields", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

}
