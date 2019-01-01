//
//  ViewController.swift
//  Pokemon Go Get Em
//
//  Created by Charles Martin Reed on 12/31/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    //MARK:- @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK:- Properties
    var manager = CLLocationManager()
    var updateCount = 0
    var pokemonArray = [Pokemon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        
        //grab your Pokemon from CoreData
        pokemonArray = getAllPokemon()
        
        //check whether or not the user has authorized location gathering
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            setupPlayerLocation()
        } else {
            manager.requestWhenInUseAuthorization()
        }
        
    }

    //MARK:- Location
    private func setupPlayerLocation() {
        
        mapView.showsUserLocation = true
        manager.startUpdatingLocation()
        mapView.delegate = self
        
        //here, we'll start creating new Pokemon after some interval, at a random location
//        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { (_) in
//            //place the pokemon on the screen
//        }
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(generateNewPokemonOnMap), userInfo: nil, repeats: true)
    }
    
    @objc private func generateNewPokemonOnMap() {
        //get the user's starting location
        if let center = manager.location?.coordinate {
            
            //generate a random location for the pokemon
            var annoCoord = center
            annoCoord.latitude += (Double.random(in: 0...200) - 100.0) / 5000.0
            annoCoord.longitude += (Double.random(in: 0...200) - 100.0) / 5000.0
            
            //grab a random pokemon from the array
            if let pokemon = pokemonArray.randomElement() {
                //create the annotation
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //first time authorization use case
        switch status {
        case .authorizedWhenInUse:
            setupPlayerLocation()
        case .denied:
            //TODO: Implement a display alert func that can handle these fail states
            print("location update denied")
        case .restricted:
            print("location updating is restricted on device")
        default:
            break
        }
    }
    
    //MARK:- Custom annotation view method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //access the annotation view
        let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        //if the annotation is representing the user
        if annotation is MKUserLocation {
            //find the player image in the bundle and use it as our annotation pin
            guard let playerImage = Bundle.main.path(forResource: "player", ofType: "png") else { return nil }
            annoView.image = UIImage(contentsOfFile: playerImage)
            
            var frame = annoView.frame
            frame.size.height = 50
            frame.size.width = 50
            annoView.frame = frame
        }
        
        return annoView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //now each time this function gets called, we should use the update count to make sure we're not constantly centering
        if updateCount < 3 {
            centerMapViewOnUser(animated: false)
            updateCount += 1
        } else {
            manager.stopUpdatingLocation()
        }
        
        
    }

    
    //MARK:- @IBActions
    @IBAction func centerMapButtonTapped(_ sender: UIButton) {
        centerMapViewOnUser(animated: true)
    }
    
    private func centerMapViewOnUser(animated: Bool) {
        //get the user location from the manager
        guard let center = manager.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 100, longitudinalMeters: 100) //translates to roughly 110 yards
        mapView.setRegion(region, animated: animated)

    }
    

}

extension MapViewController: CLLocationManagerDelegate {
    
}

extension MapViewController: MKMapViewDelegate {
}

