//
//  Food.swift
//  FitTrack
//  Reference: https://www.brianadvent.com/create-weather-app-scratch/
//           : http://kilo-loco.teachable.com/courses/196880/lectures/3268575
//  Created by Thev  on 11/6/19.
//  Copyright © 2019 Thev. All rights reserved.
//

import Foundation

struct Food {
    var searched:String  //Stores the string the user searched for.
    var calories:Int
    var weight: Int
    let label:String
    var imgUrl:String
    var quantity:Int
    let foodId:String      //Food ID is needed to send POST request for nutrient info.
    var measureURI:String  //Quantity measurement is required to get nutrient data
    
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(json:[String:Any]) throws {
        

        //Get label from HTTP get request to edamam api
        guard let label = json["label"] as? String else {throw SerializationError.missing("label is missing")}
        //Get fooId from HTTP get request edamam api
        guard let foodId = json["foodId"] as? String else {throw SerializationError.missing("Food id is missing")}
        //Get imageurl from HTTP GET request to edamam api
        self.imgUrl = json["image"] as? String ?? "https://www.edamam.com/food-img/42c/"
        //Get nutrient info from edamam after snding POST request
        guard let nutrients = json["nutrients"] as? NSDictionary else {throw SerializationError.missing("Nutrition data is missing")}
        
        
        self.calories = nutrients["ENERC_KCAL"] as? Int ?? 0
        self.foodId   = foodId  
        self.label    = label
        self.measureURI = "http://www.edamam.com/ontologies/edamam.owl#Measure_unit"
        self.quantity = 1
        self.weight = -1
        self.searched = ""
        
        
        
    }
    //Data required to make url to access Edamam Api
    static let appID = "&app_id=f776cd93"
    static let appKey = "&app_key=a5f89146e422a17b07f3c94de20f1b9a"
    static let basePath = "https://api.edamam.com/api/food-database/parser?ingr="
    
    
    //This Function takes a search String and requests data on it from the API.
    //On completion provides an array with Food Objects.
    static func foodInfo (withSearchString search:String, completion: @escaping ([Food]) -> ()) {
        
        //Api requires the search string to have its spaces replaced with "%20"
        let searchString = search.replacingOccurrences(of: " ", with: "%20")
        let url = basePath + searchString + appID + appKey
        
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
        
        var foodArray:[Food] = []
        
       //GET request from Api. The JSON string recieved is processed and stored as Food Objects
        if let data = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                    if  let nutrition = json["parsed"] as? [[String:Any]] {
                        for dataPoint in nutrition {
                            if let foodItem = dataPoint["food"] as? [String:Any]{
                                if var foodObject =  try? Food(json: foodItem) {
                                    if let measure = dataPoint["measure"] as? NSDictionary {
                                        foodObject.measureURI = measure["uri"] as! String
                                    }
                                    if let quantity = dataPoint["quantity"] as? Int {
                                        foodObject.quantity = quantity
                                    }
   
                                    foodArray.append(foodObject)
                                }
                            }
                        }
                    }
                }
            }
            catch {
                print(error.localizedDescription)
            }
            
            
            completion(foodArray)
        }
     }
         task.resume()
    }
    
}
