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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        
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

    
    //MARK:- @IBActions
    @IBAction func centerMapButtonTapped(_ sender: UIButton) {
        //get the user location from the manager
        guard let center = manager.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 100, longitudinalMeters: 100) //translates to roughly 110 yards
        mapView.setRegion(region, animated: true)
    }
    

}

extension MapViewController: CLLocationManagerDelegate {
    
}

extension MapViewController: MKMapViewDelegate {
}

