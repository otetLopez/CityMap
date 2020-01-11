//
//  ViewController.swift
//  CityMap
//
//  Created by otet_tud on 1/10/20.
//  Copyright © 2020 otet_tud. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var coordinates = Array<Array<Double>>()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Define Latitude and Longitude of a specific location ex. Ontario
        let latidude : CLLocationDegrees = 43.64//51.25//43.64
        let longitude: CLLocationDegrees = -79.38//-85.32//-79.38

        // Define the Deltas of Latitude and Longitude
        let latDelta : CLLocationDegrees = 1.0
        let longDelta : CLLocationDegrees = 1.0
        
        // Define the Span
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        // Define the location
        let location = CLLocationCoordinate2D(latitude: latidude, longitude: longitude)
        
        // Define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // Set MapView with the set region
        mapView.setRegion(region, animated: true)
        
        // Add a long press gesture
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        mapView.addGestureRecognizer(uilpgr)
        
    }
    
    @objc func longPress(gestureRecognizer : UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
       
        // PIN Location: Add annotation
        let annotation = MKPointAnnotation()
        annotation.title = "Pinned Location"
        annotation.coordinate = coordinate
        
        if checkCoordinate(coordinate: coordinate) {
            mapView.addAnnotation(annotation)
            addLocation(coordinate: coordinate)
        } else {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func checkCoordinate(coordinate : CLLocationCoordinate2D) -> Bool {
        var i : Int = 0
        for idx in coordinates {
            // check latitude not within range
            //print("latitude: \(idx[0])")
            //print("longitude: \(idx[1])")
            let newCoordinate : Array<Double> = [ Double(round(10000*coordinate.latitude)/10000), Double(round(10000*coordinate.longitude)/10000)]
            if ((idx[0] - 0.001) <= coordinate.latitude && coordinate.latitude <= (idx[0] + 0.001)) && ((idx[1] - 0.001) <= coordinate.longitude && coordinate.longitude <= (idx[1] + 0.001)) {
                print("Similar coordinates \(newCoordinate)")
                coordinates.remove(at: i)
                return false
            }
            i += 1
        }
       return true
    }
    
    func addLocation(coordinate : CLLocationCoordinate2D) {
        let newCoordinate : Array<Double> = [ Double(round(1000*coordinate.latitude)/1000), Double(round(1000*coordinate.longitude)/1000)]
        coordinates.append(newCoordinate)
        print("--------------------")
        for idx in coordinates {
            print("\(idx)")
        }
        print("--------------------")
    }


}

