//
//  ViewController.swift
//  weather
//
//  Created by Admin on 01.05.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var cityNameLabel: UILabel!
   	@IBOutlet weak var cityTempLabel: UILabel!
    
    @IBAction func refreshDataButtonClicked(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //apiid=c48ad607e70ed8c8fe03a426f8a15f46
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?q=Samara&appid=c48ad607e70ed8c8fe03a426f8a15f46")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getWeatherData(urlString: String){
        let url = NSURL(string: urlString)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!){ (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.setLabels(data!)
            })
        }
        task.resume()
    }
    
    func setLabels(weatherData: NSData){
        //var jsonError : NSError
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(weatherData, options: []) as! NSDictionary
            // если в json данных есть name, то приравниваем в новую переменную
            if let name = json["name"] as? 	String{
                cityNameLabel.text = name
            }
            
            if let main = json["main"] as? NSDictionary{
                if let temp = main["temp"] as? Double {
                    let tempC = (temp - 273.15)
                    cityTempLabel.text = String(format: "%.1f", tempC)
                }
            }
        } catch {
            print("error: \(error)")
        }
    }

}

