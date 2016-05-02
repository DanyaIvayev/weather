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
    @IBOutlet weak var cityGroupWeather: UILabel!
    @IBOutlet weak var cityDescriptionLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBAction func refreshDataButtonClicked(sender: AnyObject) {
        
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?q="+(cityNameTextField.text)!+"&appid=c48ad607e70ed8c8fe03a426f8a15f46")
    }
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //apiid=c48ad607e70ed8c8fe03a426f8a15f46
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        cityNameTextField.text="Samara"
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
            
            if let weather = json["weather"] as? NSArray{
                if let weatherDict = weather[0] as? NSDictionary {
                    if let type = weatherDict["main"] as? String{
                        cityGroupWeather.text = type
                        if let desc = weatherDict["description"] as? String{
                            cityDescriptionLabel.text = desc
                            switch type{
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
