//
//  ViewController.swift
//  ISSPass
//
//  Created by Jeff Kral on 2/15/18.
//  Copyright © 2018 Jeff Kral. All rights reserved.
//

import UIKit
import CoreLocation

struct Pass: Codable {
    var risetime: Float?
    let duration: Float?
}

struct JsonResponse: Codable {
    let message: String
    let request: [String:Float]
    let response: [Pass]
}

class HomeTableViewController: UITableViewController, CLLocationManagerDelegate {
 
    var locationManager: CLLocationManager!
    var passesToDisplay = [Pass]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.stopUpdatingLocation()
        
        setupUI()
        fetchData()
    }
    
    func setupUI() {
        
        let backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "ISSBackgroundImage 2"))
        backgroundImageView.clipsToBounds = true
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.isUserInteractionEnabled = true
        backgroundImageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
        tableView.tableHeaderView = backgroundImageView
        
        let updateButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = .white
            button.layer.cornerRadius = 8
            button.setTitle("Update ISS Pass Times", for: .normal)
            button.setTitleColor(.blue, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            button.addTarget(self, action: #selector(handleUpdate), for: .touchUpInside)
            return button
        }()
        
        backgroundImageView.addSubview(updateButton)
        // anchor function from Extensions file
        let buttonWidth: CGFloat = 240
        updateButton.anchor(top: nil, left: backgroundImageView.leftAnchor, bottom: backgroundImageView.bottomAnchor, right: backgroundImageView.rightAnchor, paddingTop: 0, paddingLeft: (backgroundImageView.frame.width - buttonWidth) / 2, paddingBottom: 14, paddingRight: (backgroundImageView.frame.width - buttonWidth) / 2, width: buttonWidth, height: 45)
    }
    
    @objc func handleUpdate() {
        passesToDisplay = []
        fetchData()
        self.tableView.reloadData()
    }
    
    func fetchData() {
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) {
            
            guard let lat = locationManager.location?.coordinate.latitude else { return }
            guard let lon = locationManager.location?.coordinate.longitude else { return }

            let jsonUrlString = "http://api.open-notify.org/iss-pass.json?lat=\(lat)&lon=\(lon)"
            guard let url = URL(string: jsonUrlString) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                if let err = err {
                    print("Error fetching json:", err)
                }
                
                guard let data = data else { return }
                
                do {
                    let jsonResponse = try JSONDecoder().decode(JsonResponse.self, from: data)
                    let passes = jsonResponse.response
                    
                    DispatchQueue.main.sync {
                        for pass in passes {
                            self.passesToDisplay.append(pass)
                        }
                        self.tableView.reloadData()
                        print(self.passesToDisplay.count)
                    }
                } catch let jsonErr {
                    print("Error serializing Json:", jsonErr)
                }
                }.resume()
        } else {
            print("not authroized")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") ?? UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cellId")

        guard let duration = passesToDisplay[indexPath.item].duration else { return cell }
        
        let unixTime = passesToDisplay[indexPath.item].risetime!
        let unixTimeDouble = Double(unixTime)
        let date = Date(timeIntervalSince1970: unixTimeDouble)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let risetime = dateFormatter.string(from: date)
        
        cell.textLabel?.text = "ISS Risetime: \(risetime)"
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        cell.detailTextLabel?.text = "Duration: \(Int(duration) / 60) min \(Int(duration.truncatingRemainder(dividingBy: 60))) sec"
        cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passesToDisplay.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

