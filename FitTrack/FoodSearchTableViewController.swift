//
//  FoodSearchTableViewController.swift
//  FitTrack
//  Reference: http://kilo-loco.teachable.com/courses/196880/lectures/3268575
//             http://brainwashinc.com/2017/07/21/loading-activity-indicator-ios-swift/
//  Created by Ash  on 13/6/19.
//  Copyright © 2019 Thev. All rights reserved.
//

import UIKit

class FoodSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    

    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var foodSearchResults =  [Food]()   //Array to hold food objects
    var nutritionData = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    //Search bar functionality
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchString = searchBar.text, !searchString.isEmpty{
            updateFoodSearch(searchString: searchString)
        }
    }
    
    
    //Main function to get food data from API
    func updateFoodSearch(searchString:String){
        
        //Calls foodInfo function in food to GET search string data from API
        Food.foodInfo(withSearchString:searchString) { (results:[Food]) in
            
            self.foodSearchResults = results
            let nutriJson = foodLoad(foodSearchResults: self.foodSearchResults)
            
            getNutritionData(foodJson:nutriJson,foodSearchResult: self.foodSearchResults){(foodArray:[Food]) in
                self.foodSearchResults = foodArray
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if self.foodSearchResults.isEmpty {
                        let alert = UIAlertController(title: "No Result/s", message: "Please type in a valid food item.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            }
         }

        
        
        struct foodData: Codable {
            var quantity: Int
            var measureURI:String
            var foodId: String
        }
        
        struct foodItem: Codable {
            var ingredients: [foodData]
        }
        
        // Function to format data in food Item into JSON format for sending back to API
        func foodLoad(foodSearchResults: [Food]) -> String{
            
            var returnString:String
            returnString = ""
            for foodObject in foodSearchResults {
                let foodInfo = foodData(quantity: foodObject.quantity, measureURI: foodObject.measureURI, foodId: foodObject.foodId)
                let foodFormatting = foodItem(ingredients: [foodInfo])
                let jsonEncoder = JSONEncoder()
                let jsonData = try! jsonEncoder.encode(foodFormatting)
                let jsonString = String(data: jsonData, encoding: .utf8)
                returnString = jsonString!.replacingOccurrences(of: "\\/", with: "/")
            }
            return (returnString)
        }
        
        //Function to send POST Json to API and get nutrition information based on quantity
        func getNutritionData(foodJson: String,foodSearchResult:[Food],completion: @escaping ([Food]) -> ()){
            DispatchQueue.main.async {
                self.showSpinner(onView: self.view)
            }
            
            var nutritionData:[Int] = []  // Array to hold Nutrition data i.e: Calories and Weight in grams
            var foodArray:[Food]          // Array to hold Food objects
            foodArray = self.foodSearchResults
            //URL for Json POST
            guard let url = URL(string: "https://api.edamam.com/api/food-database/nutrients?app_id=f776cd93&app_key=a5f89146e422a17b07f3c94de20f1b9a") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = Data(foodJson.utf8)
            
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                //Using JSON response from POST to get calorie and weigth information about food item
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                            if  let calories = json["calories"] as? Int {
                                nutritionData.append(calories)
                            }
                            if  let weight = json["totalWeight"] as? Int {
                                nutritionData.append(weight)
                            }
                        }
                        // Storing it in a food object array to be sent back to calorie counter
                        if foodArray.count > 0 {
                            foodArray[0].searched = searchString
                            if nutritionData.count == 2 {
                                foodArray[0].calories = nutritionData[0]
                                foodArray[0].weight = nutritionData[1]
                            }
                            if nutritionData.count == 1 {
                                foodArray[0].calories = 0
                                
                            }
                            
                        }
                        
                    } catch {
                        print(error)
                    }
                    DispatchQueue.main.async {
                        self.removeSpinner()
                    }
                    
                    completion(foodArray)
                }
                }.resume()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodSearchResults.count
    }

    //Create cells for results after food search
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell") as! FoodSearchTableViewCell
        cell.searchLabel?.text = foodSearchResults.first?.searched
        cell.foodLabel?.text = foodSearchResults.first?.label
        cell.foodLabel.lineBreakMode = .byWordWrapping
        cell.foodLabel.numberOfLines = 0
        
        if foodSearchResults.first?.calories ?? 0 > 0{
            cell.calorieLabel.text = String(foodSearchResults.first?.calories ?? 0)
        }
        else {
            cell.calorieLabel.text = "N/A"
        }
        
        if foodSearchResults.first?.weight ?? 0 > 0{
            cell.weightLabel.text = String(foodSearchResults.first?.weight ?? 0)
        }
        else {
            cell.weightLabel.text = "N/A"
        }
        
        let url = URL(string: foodSearchResults.first!.imgUrl)!
        let data = try? Data(contentsOf: url)
        
        if let imageData = data {
            let image = UIImage(data: imageData)
        cell.foodImage.image = image
        }
        
        return cell
    }
    
    
    //Segue to send food object back to calorie counter
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "showCalorie" {
        let foodObjectSend = self.foodSearchResults
        
        let destinationVC = segue.destination as! CounterViewController
        destinationVC.receivedFoodObjects = foodObjectSend
        }
        
    }
    

}

// Action indicator to display while app is getting info from API
var vSpinner : UIView?
extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.color = .black
        ai.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        ai.center = spinnerView.center
       
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            UIApplication.shared.endIgnoringInteractionEvents()
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
