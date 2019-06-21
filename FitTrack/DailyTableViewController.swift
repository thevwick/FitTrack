//
//  DailyTableViewController.swift
//  FitTrack
//
//  Created by Ash  on 17/6/19.
//  Copyright © 2019 Thev. All rights reserved.
//

import UIKit

//Common to every week
class DailyTableViewController: UITableViewController {
    
    var receivedWeekName = ""
    var daySend = ""
    let days = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath);
        cell.textLabel?.text = days[indexPath.row]
        return cell;
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toExercises" {
            let indexPath = tableView.indexPathForSelectedRow
            let currentCell = tableView.cellForRow(at: indexPath!) as UITableViewCell?;
            let daySend = (currentCell?.textLabel!.text!)!
            let destinationVC = segue.destination as! ExercisesTableViewController
            destinationVC.receivedDay = daySend
            destinationVC.receivedWeek = self.receivedWeekName
        }
    }

}
