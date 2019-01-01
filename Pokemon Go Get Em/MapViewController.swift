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
    var allPokemon = [Pokemon]()
    var pokemonSpawnRate: Double = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //grab your Pokemon from CoreData
        allPokemon = getAllPokemon()
        
        //seed an initial collection of Pokemon on screen
        generateNewPokemonOnMap()
        
        manager.delegate = self
        //check whether or not the user has authorized location gathering
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            setupPlayerLocation()
        } else {
            manager.requestWhenInUseAuthorization()
        }
        
    }

    //MARK:- Location methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //first time authorization use case
        switch status {
        case .authorizedWhenInUse:
            setupPlayerLocation()
            //TODO: Implement a display alert func that can handle these fail states
        case .denied:
            print("location update denied")
        case .restricted:
            print("location updating is restricted on device")
        default:
            break
        }
    }
    
    private func setupPlayerLocation() {
        
        mapView.showsUserLocation = true
        manager.startUpdatingLocation()
        mapView.delegate = self
        
        //here, we'll start creating new Pokemon after some interval, at a random location
        //place the pokemon on the screen
        Timer.scheduledTimer(timeInterval: pokemonSpawnRate, target: self, selector: #selector(generateNewPokemonOnMap), userInfo: nil, repeats: true)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //now each time this function gets called, we should use the update count to make sure we're not constantly centering
        if updateCount < 3 {
            if let center = manager.location?.coordinate {
                let region = MKCoordinateRegion(center: center, latitudinalMeters: 200, longitudinalMeters: 200)
                mapView.setRegion(region, animated: false)
            }
            updateCount += 1
        } else {
            manager.stopUpdatingLocation()
        }
    }
    
    //MARK:- Pokemon generation method
    @objc private func generateNewPokemonOnMap() {
        //get the user's starting location
        if let center = manager.location?.coordinate {
            
            let spawnAmount = Int.random(in: 0...3)
            //grab a random pokemon from the array
            for _ in 0...spawnAmount {
                if let randomPokemon = allPokemon.randomElement() {
                    //generate a random location for the pokemon
                    var annoCoord = center
                    //create the annotation and add it to the mapView
                    annoCoord.latitude += (Double.random(in: 0...200) - 100.0) / 20000.0
                    annoCoord.longitude += (Double.random(in: 0...200) - 100.0) / 20000.0

                    let anno = PokeAnnotation(coordinate: annoCoord, pokemon: randomPokemon)
                    mapView.addAnnotation(anno)
                }
            }
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
            print(playerImage)
        } else {
            //if the annotation is representing the Pokemon
            if let pokeAnnotation = annotation as? PokeAnnotation {
                guard let pokeImage = Bundle.main.path(forResource: pokeAnnotation.pokemon.name, ofType: "png") else { return nil }
                annoView.image = UIImage(contentsOfFile: pokeImage)
            }
        }
        
        //set the frame size for our custom annotation
        var frame = annoView.frame
        frame.size.height = 50.0
        frame.size.width = 50.0
        annoView.frame = frame

        return annoView
    }
    
    //MARK:- Pokemon capture methods
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        //when the TRAINER is checked
        if view.annotation is MKUserLocation {
            
        } else {
            //when the POKEMON is tapped - can it be caught?
            //1. center map on the user
            if let center = manager.location?.coordinate {
                if let pokeLocationCenter = view.annotation?.coordinate {
                    //create a region that zooms in on the Pokemon
                    let region = MKCoordinateRegion(center: pokeLocationCenter, latitudinalMeters: 200, longitudinalMeters: 200)
                    mapView.setRegion(region, animated: false)
                    
                    if let pokeAnnotion = view.annotation as? PokeAnnotation {
                        guard let name = pokeAnnotion.pokemon.name else { return }
                        //is the pokemon in range
                        if mapView.visibleMapRect.contains(MKMapPoint(center)) {
                            //successful CAPTURE
                            markPokemonAsCaptured(pokemon: pokeAnnotion.pokemon)
                            displayAlertForAttemptCapture(title: "You caught a \(name.capitalized)!", message: "\(name.capitalized) has been added to your Pokedex.", inRange: true)
                        } else {
                            //failed to CAPTURE
                            displayAlertForAttemptCapture(title: "You're too far away!", message: "You need to be a bit closer to \(name.capitalized) in order to attempt capturing it.", inRange: false)
                        }
                    }
                }
            }
        }
        
    }
 
    
    func markPokemonAsCaptured(pokemon: Pokemon) {
        pokemon.hasBeenCaught = true
        
        //update Core Data
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    func displayAlertForAttemptCapture(title: String, message: String, inRange: Bool) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let pokeDexAction = UIAlertAction(title: "View Pokedex", style: .default) { (_) in
            //move them to the Pokedex
            self.performSegue(withIdentifier: "moveToPokedex", sender: nil)
        }
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        //MIGHT be a better idea to create two separate display alerts here, instead of shoehorning this functionaliy here. Consider this a proof of concept.
        if inRange {
            ac.addAction(pokeDexAction)
            ac.addAction(okAction)
        } else {
            ac.addAction(okAction)
        }
        
        present(ac, animated: true, completion: nil)
    }

    
    //MARK:- @IBActions
    @IBAction func centerMapButtonTapped(_ sender: UIButton) {
        centerMapViewOnUser(animated: true)
    }
    
    private func centerMapViewOnUser(animated: Bool) {
        //get the user location from the manager
        guard let center = manager.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 200, longitudinalMeters: 200) //translates to roughly 110 yards
        mapView.setRegion(region, animated: animated)

    }
    

}

extension MapViewController: CLLocationManagerDelegate {
    
}

extension MapViewController: MKMapViewDelegate {
}

