//
//  ViewController.swift
//  weather
//
//  Created by Admin on 01.05.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit
import CoreLocation
import Darwin

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var cityNameLabel: UILabel!
    
   	@IBOutlet weak var cityTempLabel: UILabel!
    @IBOutlet weak var cityGroupWeather: UILabel!
    @IBOutlet weak var cityDescriptionLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBAction func ExitApp(sender: AnyObject) {
        exit(0)
    }
    
    let locationManager = CLLocationManager()
    
    @IBAction func refreshDataButtonClicked(sender: AnyObject) {
        
        let cityName = removeSpecialCharsFromString(cityNameTextField.text!)
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?q="+(cityName)+"&appid=c48ad607e70ed8c8fe03a426f8a15f46")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)-> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        locationManager.stopUpdatingLocation()
        NSLog(placemark.locality != nil ? placemark.locality! : "Failed!")
        cityNameTextField.text=placemark.locality != nil ? placemark.locality! : "Samara"
        let cityName = removeSpecialCharsFromString(cityNameTextField.text!)
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?q="+(cityName)+"&appid=c48ad607e70ed8c8fe03a426f8a15f46")
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
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
        Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890-(),".characters)
        return String(text.characters.filter {okayChars.contains($0) })
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
            
            if let weather = json["weather"] as? NSArray{
                if let weatherDict = weather[0] as? NSDictionary {
                    if let type = weatherDict["main"] as? String{
                        cityGroupWeather.text = type
                        if let desc = weatherDict["description"] as? String{
                            cityDescriptionLabel.text = desc
                            switch type{
                            case "Haze":
                                    let image:UIImage = UIImage(named: "haze.png")!
                                    weatherIconImageView.image=image
                            case "Clouds" :
                                    if desc == "few clouds"{
                                        let image:UIImage = UIImage(named: "cloud-sun.png")!
                                        weatherIconImageView.image=image
                                    } else {
                                        let image:UIImage = UIImage(named: "cloud.png")!
                                        weatherIconImageView.image=image
                                    }
                                
                            case "Rain" :
                                if desc == "light rain" || desc == "moderate rain" || desc == "moderate rain" || desc == "very heavy rain" || desc == "extreme rain"{
                                    let image:UIImage = UIImage(named: "drizzle-sun.png")!
                                    self.weatherIconImageView.image=image
                                }else if desc == "freezing rain"{
                                    let image:UIImage = UIImage(named: "drizzle-alt.png")!
                                    weatherIconImageView.image=image
                                }else{
                                    let image:UIImage = UIImage(named: "drizzle.png")!
                                    weatherIconImageView.image=image
                                }
                                
                            case "Drizzle" :
                                let image:UIImage = UIImage(named: "drizzle.png")!
                                weatherIconImageView.image=image
                            case "Thunderstorm":
                                let image:UIImage = UIImage(named: "lightning-rain.png")!
                                weatherIconImageView.image=image
                                
                            case "Snow" :
                                let image:UIImage = UIImage(named: "snow-alt.png")!
                                weatherIconImageView.image=image
                                
                            case "Clear":
                                let image:UIImage = UIImage(named: "sun.png")!
                                weatherIconImageView.image=image
                            default: break

                            }
                        }
                    }
                    
                    
                    //TODO analyze type and description and choose the weather icon
                    
                }
            }
            
        } catch {
            let alert = UIAlertController(title: "Error", message: "Received incorrect data", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            //print("error: \(error)")
        }
    }

}
